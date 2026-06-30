<?php

namespace App\Services;

use App\Models\Attendance;
use App\Models\AttendanceLog;
use App\Repositories\AttendanceRepository;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use InvalidArgumentException;

class AttendanceService
{
    public function __construct(
        private readonly AttendanceRepository $attendanceRepository,
        private readonly FaceEmbeddingService $faceEmbeddingService,
    ) {}

    public function checkIn(array $data, ?float $confidence = null): Attendance
    {
        // Only verify if embedding is provided and confidence is not already set
        if (isset($data['embedding']) && $confidence === null) {
            $verification = $this->faceEmbeddingService->verify(
                $data['employee_id'],
                $data['embedding']
            );

            if (! $verification['matched']) {
                throw new InvalidArgumentException($verification['message']);
            }

            $confidence = $verification['confidence'];
        }

        return DB::transaction(function () use ($data, $confidence) {
            $attendance = $this->attendanceRepository->findTodayForEmployee($data['employee_id']);

            if ($attendance?->check_in_at) {
                throw new InvalidArgumentException('Already checked in today');
            }

            $checkinFaceImagePath = null;
            if (isset($data['face_image'])) {
                $checkinFaceImagePath = $this->storeFaceImage($data['face_image'], 'attendance/checkin', $data['employee_id']);
            }

            if (! $attendance) {
                $attendance = Attendance::create([
                    'employee_id' => $data['employee_id'],
                    'site_id' => $data['site_id'],
                    'shift_id' => $data['shift_id'] ?? null,
                    'supervisor_id' => $data['supervisor_id'],
                    'attendance_date' => Carbon::today(),
                    'status' => 'present',
                    'checkin_face_image' => $checkinFaceImagePath,
                ]);
            }

            $attendance->update([
                'check_in_at' => now(),
                'check_in_latitude' => $data['latitude'] ?? null,
                'check_in_longitude' => $data['longitude'] ?? null,
                'check_in_confidence' => $confidence,
                'check_in_device_id' => $data['device_id'] ?? null,
                'supervisor_id' => $data['supervisor_id'],
                'checkin_face_image' => $checkinFaceImagePath,
            ]);

            $this->logAction($attendance, 'check_in', $data, $confidence);

            return $attendance->fresh(['employee', 'site', 'shift']);
        });
    }

    public function checkInByMatchedFace(array $data, float $confidence): Attendance
    {
        return DB::transaction(function () use ($data, $confidence) {
            $attendance = $this->attendanceRepository->findTodayForEmployee($data['employee_id']);

            if ($attendance?->check_in_at) {
                throw new InvalidArgumentException('Already checked in today');
            }

            $checkinFaceImagePath = null;
            if (isset($data['face_image'])) {
                $checkinFaceImagePath = $this->storeFaceImage($data['face_image'], 'attendance/checkin', $data['employee_id']);
            }

            if (! $attendance) {
                $attendance = Attendance::create([
                    'employee_id' => $data['employee_id'],
                    'site_id' => $data['site_id'],
                    'shift_id' => $data['shift_id'] ?? null,
                    'supervisor_id' => $data['supervisor_id'],
                    'attendance_date' => Carbon::today(),
                    'status' => 'present',
                    'checkin_face_image' => $checkinFaceImagePath,
                ]);
            }

            $attendance->update([
                'check_in_at' => now(),
                'check_in_latitude' => $data['latitude'] ?? null,
                'check_in_longitude' => $data['longitude'] ?? null,
                'check_in_confidence' => $confidence,
                'check_in_device_id' => $data['device_id'] ?? null,
                'supervisor_id' => $data['supervisor_id'],
                'checkin_face_image' => $checkinFaceImagePath,
            ]);

            $this->logAction($attendance, 'check_in', $data, $confidence);

            return $attendance->fresh(['employee', 'site', 'shift']);
        });
    }

    public function checkOut(array $data, ?float $confidence = null): Attendance
    {
        // Only verify if embedding is provided and confidence is not already set
        if (isset($data['embedding']) && $confidence === null) {
            $verification = $this->faceEmbeddingService->verify(
                $data['employee_id'],
                $data['embedding']
            );

            if (! $verification['matched']) {
                throw new InvalidArgumentException($verification['message']);
            }

            $confidence = $verification['confidence'];
        }

        return DB::transaction(function () use ($data, $confidence) {
            $attendance = $this->attendanceRepository->findTodayForEmployee($data['employee_id']);

            if (! $attendance?->check_in_at) {
                throw new InvalidArgumentException('Must check in before check out');
            }

            if ($attendance->check_out_at) {
                throw new InvalidArgumentException('Already checked out today');
            }

            $checkoutFaceImagePath = null;
            if (isset($data['face_image'])) {
                $checkoutFaceImagePath = $this->storeFaceImage($data['face_image'], 'attendance/checkout', $data['employee_id']);
            }

            $checkOut = now();
            $workedMinutes = $attendance->check_in_at->diffInMinutes($checkOut);

            $attendance->update([
                'check_out_at' => $checkOut,
                'check_out_latitude' => $data['latitude'] ?? null,
                'check_out_longitude' => $data['longitude'] ?? null,
                'check_out_confidence' => $confidence,
                'check_out_device_id' => $data['device_id'] ?? null,
                'worked_minutes' => $workedMinutes,
                'checkout_face_image' => $checkoutFaceImagePath,
            ]);

            $this->logAction($attendance, 'check_out', $data, $confidence);

            return $attendance->fresh(['employee', 'site', 'shift']);
        });
    }

    public function checkOutByMatchedFace(array $data, float $confidence): Attendance
    {
        return DB::transaction(function () use ($data, $confidence) {
            $attendance = $this->attendanceRepository->findTodayForEmployee($data['employee_id']);

            if (! $attendance?->check_in_at) {
                throw new InvalidArgumentException('Must check in before check out');
            }

            if ($attendance->check_out_at) {
                throw new InvalidArgumentException('Already checked out today');
            }

            $checkoutFaceImagePath = null;
            if (isset($data['face_image'])) {
                $checkoutFaceImagePath = $this->storeFaceImage($data['face_image'], 'attendance/checkout', $data['employee_id']);
            }

            $checkOut = now();
            $workedMinutes = $attendance->check_in_at->diffInMinutes($checkOut);

            $attendance->update([
                'check_out_at' => $checkOut,
                'check_out_latitude' => $data['latitude'] ?? null,
                'check_out_longitude' => $data['longitude'] ?? null,
                'check_out_confidence' => $confidence,
                'check_out_device_id' => $data['device_id'] ?? null,
                'worked_minutes' => $workedMinutes,
                'checkout_face_image' => $checkoutFaceImagePath,
            ]);

            $this->logAction($attendance, 'check_out', $data, $confidence);

            return $attendance->fresh(['employee', 'site', 'shift']);
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

    private function logAction(Attendance $attendance, string $action, array $data, float $confidence): void
    {
        AttendanceLog::create([
            'attendance_id' => $attendance->id,
            'employee_id' => $attendance->employee_id,
            'action' => $action,
            'logged_at' => now(),
            'latitude' => $data['latitude'] ?? null,
            'longitude' => $data['longitude'] ?? null,
            'confidence_score' => $confidence,
            'device_id' => $data['device_id'] ?? null,
            'metadata' => ['shift_id' => $data['shift_id'] ?? null],
        ]);
    }
}
