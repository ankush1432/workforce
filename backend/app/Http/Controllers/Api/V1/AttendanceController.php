<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Attendance\CheckInRequest;
use App\Http\Requests\Attendance\CheckOutRequest;
use App\Http\Resources\AttendanceResource;
use App\Repositories\AttendanceRepository;
use App\Services\AttendanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;

class AttendanceController extends Controller
{
    public function __construct(
        private readonly AttendanceRepository $repository,
        private readonly AttendanceService $attendanceService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->only([
            'employee_id', 'company_id', 'site_id', 'date_from', 'date_to', 'attendance_date',
        ]);

        $items = $this->repository->paginate($filters, (int) $request->get('per_page', 20));

        return AttendanceResource::collection($items)->response();
    }

    public function todayForEmployee(int $employeeId): JsonResponse
    {
        $attendance = $this->repository->findTodayForEmployee($employeeId);

        return response()->json([
            'data' => $attendance ? new AttendanceResource($attendance->load(['employee', 'site', 'shift'])) : null,
        ]);
    }

    public function checkIn(CheckInRequest $request): JsonResponse
    {
        try {
            $data = array_merge($request->validated(), [
                'supervisor_id' => auth('supervisor')->id(),
            ]);

            $attendance = $this->attendanceService->checkIn($data);

            return response()->json([
                'message' => 'Check-in successful',
                'data' => new AttendanceResource($attendance),
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function checkOut(CheckOutRequest $request): JsonResponse
    {
        try {
            $data = array_merge($request->validated(), [
                'supervisor_id' => auth('supervisor')->id(),
            ]);

            $attendance = $this->attendanceService->checkOut($data);

            return response()->json([
                'message' => 'Check-out successful',
                'data' => new AttendanceResource($attendance),
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }
}
