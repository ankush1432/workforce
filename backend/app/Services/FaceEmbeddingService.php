<?php

namespace App\Services;

use App\Models\Employee;
use App\Models\EmployeeFaceEmbedding;
use App\Repositories\EmployeeRepository;
use Illuminate\Support\Facades\DB;

class FaceEmbeddingService
{
    private const MATCH_THRESHOLD = 0.75;

    public function __construct(
        private readonly EmployeeRepository $employeeRepository,
    ) {}

    public function register(int $employeeId, array $embedding, int $supervisorId, ?float $qualityScore = null): EmployeeFaceEmbedding
    {
        return DB::transaction(function () use ($employeeId, $embedding, $supervisorId, $qualityScore) {
            EmployeeFaceEmbedding::where('employee_id', $employeeId)->update(['is_primary' => false]);

            $record = EmployeeFaceEmbedding::create([
                'employee_id' => $employeeId,
                'embedding' => $embedding,
                'model_version' => 'mobilefacenet-v1',
                'quality_score' => $qualityScore,
                'registered_by_supervisor_id' => $supervisorId,
                'registered_at' => now(),
                'is_primary' => true,
            ]);

            Employee::where('id', $employeeId)->update(['face_registered' => true]);

            return $record;
        });
    }

    public function getStatus(int $employeeId): array
    {
        $employee = $this->employeeRepository->find($employeeId);

        if (! $employee) {
            return [
                'employee_id' => $employeeId,
                'registration_status' => 'not_registered',
                'embedding_exists' => false,
                'face_registered' => false,
            ];
        }

        $embedding = $employee->primaryEmbedding;
        $embeddingExists = $embedding !== null;
        $faceRegistered = (bool) $employee->face_registered;

        $registrationStatus = match (true) {
            $faceRegistered && $embeddingExists => 'registered',
            $faceRegistered && ! $embeddingExists => 'pending_sync',
            default => 'not_registered',
        };

        return [
            'employee_id' => $employee->id,
            'registration_status' => $registrationStatus,
            'embedding_exists' => $embeddingExists,
            'face_registered' => $faceRegistered,
            'model_version' => $embedding?->model_version,
            'confidence' => $embedding?->quality_score,
            'registered_at' => $embedding?->registered_at?->toIso8601String(),
        ];
    }

    public function verify(int $employeeId, array $probeEmbedding): array
    {
        $employee = $this->employeeRepository->find($employeeId);

        if (! $employee || ! $employee->face_registered) {
            return ['matched' => false, 'confidence' => 0, 'message' => 'Face not registered'];
        }

        $stored = $employee->primaryEmbedding;

        if (! $stored) {
            return ['matched' => false, 'confidence' => 0, 'message' => 'No embedding found'];
        }

        $confidence = $this->cosineSimilarity($probeEmbedding, $stored->embedding);
        $matched = $confidence >= self::MATCH_THRESHOLD;

        return [
            'matched' => $matched,
            'confidence' => round($confidence, 4),
            'threshold' => self::MATCH_THRESHOLD,
            'message' => $matched ? 'Face verified' : 'Face mismatch',
        ];
    }

    private function cosineSimilarity(array $a, array $b): float
    {
        $dot = 0.0;
        $normA = 0.0;
        $normB = 0.0;
        $len = min(count($a), count($b));

        for ($i = 0; $i < $len; $i++) {
            $dot += $a[$i] * $b[$i];
            $normA += $a[$i] ** 2;
            $normB += $b[$i] ** 2;
        }

        if ($normA == 0 || $normB == 0) {
            return 0.0;
        }

        return $dot / (sqrt($normA) * sqrt($normB));
    }
}
