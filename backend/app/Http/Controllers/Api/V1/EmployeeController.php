<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Employee\StoreEmployeeRequest;
use App\Http\Requests\Employee\UpdateEmployeeRequest;
use App\Http\Resources\EmployeeResource;
use App\Repositories\EmployeeRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EmployeeController extends Controller
{
    public function __construct(private readonly EmployeeRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(['search', 'company_id', 'site_id', 'supervisor_id', 'face_registered', 'is_active']);

        // If request is from supervisor, filter by their supervisor_id
        $auth = auth('supervisor');
        if ($auth->check()) {
            $supervisor = $auth->user();
            $filters['supervisor_id'] = $supervisor->supervisor_id ?? $supervisor->id;
        }

        $items = $this->repository->paginate($filters, (int) $request->get('per_page', 15));

        return EmployeeResource::collection($items)->response();
    }

    public function store(StoreEmployeeRequest $request): JsonResponse
    {
        $employee = $this->repository->create($request->validated());

        return (new EmployeeResource($employee->load(['company', 'site'])))->response()->setStatusCode(201);
    }

    public function show(int $id): JsonResponse
    {
        $employee = $this->repository->find($id);

        abort_if(! $employee, 404);

        return response()->json(['data' => new EmployeeResource($employee)]);
    }

    public function update(UpdateEmployeeRequest $request, int $id): JsonResponse
    {
        $employee = $this->repository->update($id, $request->validated());

        return response()->json(['data' => new EmployeeResource($employee)]);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->repository->delete($id);

        return response()->json(['message' => 'Deleted']);
    }
}
