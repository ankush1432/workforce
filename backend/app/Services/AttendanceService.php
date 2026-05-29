<?php

namespace App\Services;

use App\Models\Attendance;
use App\Models\AttendanceLog;
use App\Repositories\AttendanceRepository;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

class AttendanceService
{
    public function __construct(
        private readonly AttendanceRepository $attendanceRepository,
        private readonly FaceEmbeddingService $faceEmbeddingService,
    ) {}

    public function checkIn(array $data): Attendance
    {
        $verification = $this->faceEmbeddingService->verify(
            $data['employee_id'],
            $data['embedding']
        );

        if (! $verification['matched']) {
            throw new InvalidArgumentException($verification['message']);
        }

        return DB::transaction(function () use ($data, $verification) {
            $attendance = $this->attendanceRepository->findTodayForEmployee($data['employee_id']);

            if ($attendance?->check_in_at) {
                throw new InvalidArgumentException('Already checked in today');
            }

            if (! $attendance) {
                $attendance = Attendance::create([
                    'employee_id' => $data['employee_id'],
                    'site_id' => $data['site_id'],
                    'shift_id' => $data['shift_id'] ?? null,
                    'supervisor_id' => $data['supervisor_id'],
                    'attendance_date' => Carbon::today(),
                    'status' => 'present',
                ]);
            }

            $attendance->update([
                'check_in_at' => now(),
                'check_in_latitude' => $data['latitude'] ?? null,
                'check_in_longitude' => $data['longitude'] ?? null,
                'check_in_confidence' => $verification['confidence'],
                'check_in_device_id' => $data['device_id'] ?? null,
                'supervisor_id' => $data['supervisor_id'],
            ]);

            $this->logAction($attendance, 'check_in', $data, $verification['confidence']);

            return $attendance->fresh(['employee', 'site', 'shift']);
        });
    }

    public function checkOut(array $data): Attendance
    {
        $verification = $this->faceEmbeddingService->verify(
            $data['employee_id'],
            $data['embedding']
        );

        if (! $verification['matched']) {
            throw new InvalidArgumentException($verification['message']);
        }

        return DB::transaction(function () use ($data, $verification) {
            $attendance = $this->attendanceRepository->findTodayForEmployee($data['employee_id']);

            if (! $attendance?->check_in_at) {
                throw new InvalidArgumentException('Must check in before check out');
            }

            if ($attendance->check_out_at) {
                throw new InvalidArgumentException('Already checked out today');
            }

            $checkOut = now();
            $workedMinutes = $attendance->check_in_at->diffInMinutes($checkOut);

            $attendance->update([
                'check_out_at' => $checkOut,
                'check_out_latitude' => $data['latitude'] ?? null,
                'check_out_longitude' => $data['longitude'] ?? null,
                'check_out_confidence' => $verification['confidence'],
                'check_out_device_id' => $data['device_id'] ?? null,
                'worked_minutes' => $workedMinutes,
            ]);

            $this->logAction($attendance, 'check_out', $data, $verification['confidence']);

            return $attendance->fresh(['employee', 'site', 'shift']);
        });
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
