<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\SupervisorResource;
use App\Repositories\SupervisorRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SupervisorController extends Controller
{
    public function __construct(private readonly SupervisorRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        return SupervisorResource::collection(
            $this->repository->paginate($request->only(['search', 'company_id', 'site_id', 'is_active']))
        )->response();
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'company_id' => ['required', 'exists:companies,id'],
            'site_id' => ['nullable', 'exists:sites,id'],
            'employee_code' => ['required', 'string', 'unique:supervisors,employee_code'],
            'first_name' => ['required', 'string'],
            'last_name' => ['required', 'string'],
            'email' => ['required', 'email', 'unique:supervisors,email'],
            'phone' => ['nullable', 'string'],
            'password' => ['required', 'string', 'min:6'],
            'is_active' => ['boolean'],
        ]);

        $supervisor = $this->repository->create($data);

        return (new SupervisorResource($supervisor))->response()->setStatusCode(201);
    }

    public function show(int $id): JsonResponse
    {
        return response()->json(['data' => new SupervisorResource($this->repository->findOrFail($id))]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'first_name' => ['sometimes', 'string'],
            'last_name' => ['sometimes', 'string'],
            'email' => ['sometimes', 'email'],
            'phone' => ['nullable', 'string'],
            'password' => ['nullable', 'string', 'min:6'],
            'site_id' => ['nullable', 'exists:sites,id'],
            'is_active' => ['boolean'],
        ]);

        return response()->json(['data' => new SupervisorResource($this->repository->update($id, $data))]);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->repository->delete($id);

        return response()->json(['message' => 'Deleted']);
    }
}
