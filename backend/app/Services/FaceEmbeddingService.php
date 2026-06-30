<?php

namespace App\Services;

use App\Models\Employee;
use App\Models\EmployeeFaceEmbedding;
use App\Repositories\EmployeeRepository;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class FaceEmbeddingService
{
    private const MATCH_THRESHOLD = 0.75;
    private const DUPLICATE_THRESHOLD = 0.5;

    public function __construct(
        private readonly EmployeeRepository $employeeRepository,
    ) {}

    public function register(int $employeeId, array $embedding, int $supervisorId, ?float $qualityScore = null, ?string $faceImageBase64 = null): array
    {
        // Log registration attempt with embedding details
        \Log::info('Face registration attempt', [
            'employee_id' => $employeeId,
            'supervisor_id' => $supervisorId,
            'quality_score' => $qualityScore,
            'embedding_length' => count($embedding),
            'embedding_sample' => array_slice($embedding, 0, 5),
        ]);

        // Check for duplicate faces before registration
        $duplicateCheck = $this->checkDuplicateFace($embedding, $employeeId);

        // Log duplicate check results
        \Log::info('Duplicate face check completed', [
            'employee_id' => $employeeId,
            'is_duplicate' => $duplicateCheck['is_duplicate'],
            'best_similarity' => $duplicateCheck['similarity'] ?? 0,
            'threshold' => self::DUPLICATE_THRESHOLD,
            'matched_employee_id' => $duplicateCheck['employee_id'] ?? null,
            'matched_employee_name' => $duplicateCheck['employee_name'] ?? null,
        ]);

        if ($duplicateCheck['is_duplicate']) {
            // Log duplicate face detection
            \Log::warning('Duplicate face registration BLOCKED', [
                'registering_employee_id' => $employeeId,
                'existing_employee_id' => $duplicateCheck['employee_id'],
                'existing_employee_name' => $duplicateCheck['employee_name'],
                'similarity' => $duplicateCheck['similarity'],
                'threshold' => self::DUPLICATE_THRESHOLD,
            ]);

            return [
                'success' => false,
                'type' => 'duplicate_face',
                'message' => 'This face is already registered to another employee',
                'employee_id' => $duplicateCheck['employee_id'],
                'employee_name' => $duplicateCheck['employee_name'],
                'similarity' => $duplicateCheck['similarity'],
            ];
        }

        // Log successful face registration start
        \Log::info('Face registration proceeding (no duplicate found)', [
            'employee_id' => $employeeId,
            'supervisor_id' => $supervisorId,
            'quality_score' => $qualityScore,
        ]);

        return DB::transaction(function () use ($employeeId, $embedding, $supervisorId, $qualityScore, $faceImageBase64) {
            EmployeeFaceEmbedding::where('employee_id', $employeeId)->update(['is_primary' => false]);

            $faceImagePath = null;
            if ($faceImageBase64) {
                $faceImagePath = $this->storeFaceImage($faceImageBase64, 'registrations', $employeeId);
            }

            $record = EmployeeFaceEmbedding::create([
                'employee_id' => $employeeId,
                'embedding' => $embedding,
                'face_image_path' => $faceImagePath,
                'model_version' => 'mobilefacenet-v1',
                'quality_score' => $qualityScore,
                'registered_by_supervisor_id' => $supervisorId,
                'registered_at' => now(),
                'is_primary' => true,
            ]);

            Employee::where('id', $employeeId)->update(['face_registered' => true]);

            // Log successful face registration
            \Log::info('Face registration completed successfully', [
                'employee_id' => $employeeId,
                'supervisor_id' => $supervisorId,
                'embedding_id' => $record->id,
                'quality_score' => $qualityScore,
            ]);

            return [
                'success' => true,
                'embedding' => $record,
            ];
        });
    }

    private function storeFaceImage(string $base64Image, string $folder, int $employeeId): string
    {
        // Remove data URL prefix if present
        $imageData = preg_replace('/^data:image\/\w+;base64,/', '', $base64Image);
        $imageData = base64_decode($imageData);
        
        $fileName = "face_{$employeeId}_" . time() . '.jpg';
        $path = "{$folder}/{$fileName}";
        
        Storage::disk('public')->put($path, $imageData);
        
        return $path;
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

    public function checkDuplicateFace(array $embedding, ?int $excludeEmployeeId = null): array
    {
        $embeddings = EmployeeFaceEmbedding::where('is_primary', true)
            ->when($excludeEmployeeId, fn ($q) => $q->where('employee_id', '!=', $excludeEmployeeId))
            ->get();

        \Log::info('Checking for duplicate faces', [
            'total_embeddings_to_check' => $embeddings->count(),
            'exclude_employee_id' => $excludeEmployeeId,
            'threshold' => self::DUPLICATE_THRESHOLD,
        ]);

        $bestMatch = null;
        $bestSimilarity = 0;
        $allSimilarities = [];

        foreach ($embeddings as $stored) {
            $similarity = $this->cosineSimilarity($embedding, $stored->embedding);
            $allSimilarities[] = [
                'employee_id' => $stored->employee_id,
                'similarity' => round($similarity, 4),
            ];
            
            if ($similarity > $bestSimilarity) {
                $bestSimilarity = $similarity;
                $bestMatch = $stored;
            }
        }

        \Log::info('Similarity check results', [
            'best_similarity' => round($bestSimilarity, 4),
            'best_match_employee_id' => $bestMatch?->employee_id,
            'all_similarities' => $allSimilarities,
        ]);

        if ($bestMatch && $bestSimilarity >= self::DUPLICATE_THRESHOLD) {
            $employee = $this->employeeRepository->find($bestMatch->employee_id);
            \Log::warning('Duplicate face detected', [
                'matched_employee_id' => $bestMatch->employee_id,
                'matched_employee_name' => $employee ? $employee->full_name : 'Unknown',
                'similarity' => round($bestSimilarity, 4),
                'threshold' => self::DUPLICATE_THRESHOLD,
            ]);
            return [
                'is_duplicate' => true,
                'employee_id' => $bestMatch->employee_id,
                'employee_name' => $employee ? $employee->full_name : 'Unknown',
                'similarity' => round($bestSimilarity, 4),
            ];
        }

        return ['is_duplicate' => false, 'similarity' => round($bestSimilarity, 4)];
    }


    public function matchEmbedding(array $probeEmbedding): array
    {
        $embeddings = EmployeeFaceEmbedding::where('is_primary', true)->get();

        $bestMatch = null;
        $bestSimilarity = 0;

        foreach ($embeddings as $stored) {
            $similarity = $this->cosineSimilarity($probeEmbedding, $stored->embedding);
            if ($similarity > $bestSimilarity) {
                $bestSimilarity = $similarity;
                $bestMatch = $stored;
            }
        }

        if ($bestMatch && $bestSimilarity >= self::MATCH_THRESHOLD) {
            $employee = $this->employeeRepository->find($bestMatch->employee_id);
            return [
                'matched' => true,
                'employee_id' => $bestMatch->employee_id,
                'employee_code' => $employee?->employee_code,
                'employee_name' => $employee?->full_name,
                'confidence' => round($bestSimilarity, 4),
                'threshold' => self::MATCH_THRESHOLD,
                'message' => 'Face matched successfully',
            ];
        }

        return [
            'matched' => false,
            'employee_id' => null,
            'confidence' => round($bestSimilarity, 4),
            'threshold' => self::MATCH_THRESHOLD,
            'message' => 'No matching face found',
        ];
    }
}
