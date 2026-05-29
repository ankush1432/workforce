<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ShiftResource;
use App\Repositories\ShiftRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ShiftController extends Controller
{
    public function __construct(private readonly ShiftRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        return ShiftResource::collection(
            $this->repository->paginate($request->only(['company_id', 'site_id', 'is_active']))
        )->response();
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'company_id' => ['required', 'exists:companies,id'],
            'site_id' => ['nullable', 'exists:sites,id'],
            'name' => ['required', 'string'],
            'start_time' => ['required'],
            'end_time' => ['required'],
            'grace_minutes' => ['nullable', 'integer'],
            'is_active' => ['boolean'],
        ]);

        return (new ShiftResource($this->repository->create($data)))->response()->setStatusCode(201);
    }

    public function show(int $id): JsonResponse
    {
        return response()->json(['data' => new ShiftResource($this->repository->findOrFail($id))]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string'],
            'start_time' => ['sometimes'],
            'end_time' => ['sometimes'],
            'grace_minutes' => ['nullable', 'integer'],
            'is_active' => ['boolean'],
        ]);

        return response()->json(['data' => new ShiftResource($this->repository->update($id, $data))]);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->repository->delete($id);

        return response()->json(['message' => 'Deleted']);
    }
}
