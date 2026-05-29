<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\OfflineSyncService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OfflineSyncController extends Controller
{
    public function __construct(private readonly OfflineSyncService $syncService) {}

    public function sync(Request $request): JsonResponse
    {
        $data = $request->validate([
            'device_id' => ['required', 'string'],
            'items' => ['required', 'array'],
            'items.*.entity_type' => ['required', 'string'],
            'items.*.action' => ['required', 'string'],
            'items.*.payload' => ['required', 'array'],
        ]);

        $results = $this->syncService->processBatch(
            auth('supervisor')->id(),
            $data['device_id'],
            $data['items']
        );

        return response()->json(['data' => $results]);
    }
}
