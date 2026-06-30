<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\DepartmentResource;
use App\Repositories\DepartmentRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DepartmentController extends Controller
{
    public function __construct(private readonly DepartmentRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        return DepartmentResource::collection(
            $this->repository->paginate($request->only(['company_id', 'is_active', 'search']))
        )->response();
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'company_id' => ['required', 'exists:companies,id'],
            'name' => ['required', 'string'],
            'code' => ['required', 'string'],
            'description' => ['nullable', 'string'],
            'is_active' => ['boolean'],
        ]);

        return (new DepartmentResource($this->repository->create($data)))->response()->setStatusCode(201);
    }

    public function show(int $id): JsonResponse
    {
        return response()->json(['data' => new DepartmentResource($this->repository->findOrFail($id))]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string'],
            'code' => ['sometimes', 'string'],
            'description' => ['nullable', 'string'],
            'is_active' => ['boolean'],
        ]);

        return response()->json(['data' => new DepartmentResource($this->repository->update($id, $data))]);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->repository->delete($id);

        return response()->json(['message' => 'Deleted']);
    }
}
