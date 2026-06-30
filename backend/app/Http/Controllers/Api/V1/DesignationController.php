<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\DesignationResource;
use App\Repositories\DesignationRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DesignationController extends Controller
{
    public function __construct(private readonly DesignationRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        return DesignationResource::collection(
            $this->repository->paginate($request->only(['company_id', 'department_id', 'is_active', 'search']))
        )->response();
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'company_id' => ['required', 'exists:companies,id'],
            'department_id' => ['nullable', 'exists:departments,id'],
            'title' => ['required', 'string'],
            'code' => ['required', 'string'],
            'description' => ['nullable', 'string'],
            'is_active' => ['boolean'],
        ]);

        return (new DesignationResource($this->repository->create($data)))->response()->setStatusCode(201);
    }

    public function show(int $id): JsonResponse
    {
        return response()->json(['data' => new DesignationResource($this->repository->findOrFail($id))]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'department_id' => ['nullable', 'exists:departments,id'],
            'title' => ['sometimes', 'string'],
            'code' => ['sometimes', 'string'],
            'description' => ['nullable', 'string'],
            'is_active' => ['boolean'],
        ]);

        return response()->json(['data' => new DesignationResource($this->repository->update($id, $data))]);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->repository->delete($id);

        return response()->json(['message' => 'Deleted']);
    }
}
