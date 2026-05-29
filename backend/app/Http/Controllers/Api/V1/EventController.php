<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\EventResource;
use App\Repositories\EventRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function __construct(private readonly EventRepository $repository) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(['status', 'search']);

        if (auth('supervisor')->check() || $request->boolean('published_only')) {
            $filters['published_only'] = true;
        }

        $items = $this->repository->paginate($filters, (int) $request->get('per_page', 20));

        return EventResource::collection($items)->response();
    }

    public function store(Request $request): JsonResponse
    {
        $data = $this->validateEvent($request);
        $data['created_by'] = auth('api')->id();

        $event = $this->repository->create($data);

        return (new EventResource($event))->response()->setStatusCode(201);
    }

    public function show(int $id): JsonResponse
    {
        return response()->json(['data' => new EventResource($this->repository->findOrFail($id))]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $event = $this->repository->update($id, $this->validateEvent($request, partial: true));

        return response()->json(['data' => new EventResource($event)]);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->repository->delete($id);

        return response()->json(['message' => 'Deleted']);
    }

    public function publish(int $id): JsonResponse
    {
        $event = $this->repository->update($id, ['status' => 'published']);

        return response()->json(['data' => new EventResource($event)]);
    }

    public function unpublish(int $id): JsonResponse
    {
        $event = $this->repository->update($id, ['status' => 'unpublished']);

        return response()->json(['data' => new EventResource($event)]);
    }

    private function validateEvent(Request $request, bool $partial = false): array
    {
        $rules = [
            'title' => [$partial ? 'sometimes' : 'required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'location' => ['nullable', 'string', 'max:255'],
            'start_date' => [$partial ? 'sometimes' : 'required', 'date'],
            'end_date' => [$partial ? 'sometimes' : 'required', 'date', 'after_or_equal:start_date'],
            'banner_image' => ['nullable', 'string', 'max:500'],
            'status' => ['sometimes', 'in:draft,published,unpublished'],
        ];

        return $request->validate($rules);
    }
}
