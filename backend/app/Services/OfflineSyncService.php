<?php

namespace App\Services;

use App\Models\OfflineSyncLog;
use Illuminate\Support\Facades\DB;

class OfflineSyncService
{
    public function __construct(
        private readonly AttendanceService $attendanceService,
        private readonly FaceEmbeddingService $faceEmbeddingService,
    ) {}

    public function processBatch(int $supervisorId, string $deviceId, array $items): array
    {
        $results = [];

        foreach ($items as $item) {
            $log = OfflineSyncLog::create([
                'supervisor_id' => $supervisorId,
                'device_id' => $deviceId,
                'entity_type' => $item['entity_type'],
                'action' => $item['action'],
                'payload' => $item['payload'],
                'status' => 'pending',
            ]);

            try {
                DB::transaction(function () use ($item, $supervisorId, $log) {
                    match ($item['action']) {
                        'check_in' => $this->attendanceService->checkIn(array_merge(
                            $item['payload'],
                            ['supervisor_id' => $supervisorId]
                        )),
                        'check_out' => $this->attendanceService->checkOut(array_merge(
                            $item['payload'],
                            ['supervisor_id' => $supervisorId]
                        )),
                        'face_register' => $this->faceEmbeddingService->register(
                            $item['payload']['employee_id'],
                            $item['payload']['embedding'],
                            $supervisorId,
                            $item['payload']['quality_score'] ?? null
                        ),
                        default => throw new \InvalidArgumentException('Unknown action'),
                    };

                    $log->update(['status' => 'synced', 'synced_at' => now()]);
                });

                $results[] = ['id' => $log->id, 'status' => 'synced'];
            } catch (\Throwable $e) {
                $log->update(['status' => 'failed', 'error_message' => $e->getMessage()]);
                $results[] = ['id' => $log->id, 'status' => 'failed', 'error' => $e->getMessage()];
            }
        }

        return $results;
    }
}
