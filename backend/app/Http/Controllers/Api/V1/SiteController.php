<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\SiteResource;
use App\Repositories\SiteRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SiteController extends Controller
{
    public function __construct(private readonly SiteRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        return SiteResource::collection(
            $this->repository->paginate($request->only(['search', 'company_id', 'is_active']))
        )->response();
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'company_id' => ['required', 'exists:companies,id'],
            'name' => ['required', 'string'],
            'code' => ['required', 'string'],
            'address' => ['nullable', 'string'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'geofence_radius_m' => ['nullable', 'integer'],
            'is_active' => ['boolean'],
        ]);

        $site = $this->repository->create($data);

        return (new SiteResource($site->load('company')))->response()->setStatusCode(201);
    }

    public function show(int $id): JsonResponse
    {
        return response()->json(['data' => new SiteResource($this->repository->findOrFail($id))]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string'],
            'code' => ['sometimes', 'string'],
            'address' => ['nullable', 'string'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'geofence_radius_m' => ['nullable', 'integer'],
            'is_active' => ['boolean'],
        ]);

        return response()->json(['data' => new SiteResource($this->repository->update($id, $data))]);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->repository->delete($id);

        return response()->json(['message' => 'Deleted']);
    }
}
