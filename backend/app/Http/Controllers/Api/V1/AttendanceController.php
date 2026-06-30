<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Attendance\CheckInRequest;
use App\Http\Requests\Attendance\CheckOutRequest;
use App\Http\Requests\Face\VerifyFaceRequest;
use App\Http\Resources\AttendanceResource;
use App\Repositories\AttendanceRepository;
use App\Services\AttendanceService;
use App\Services\FaceEmbeddingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;

class AttendanceController extends Controller
{
    public function __construct(
        private readonly AttendanceRepository $repository,
        private readonly AttendanceService $attendanceService,
        private readonly FaceEmbeddingService $faceService,
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
                'success' => true,
                'type' => 'success',
                'message' => 'Check-in successful',
                'data' => new AttendanceResource($attendance),
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json([
                'success' => false,
                'type' => 'error',
                'message' => $e->getMessage(),
            ], 422);
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
                'success' => true,
                'type' => 'success',
                'message' => 'Check-out successful',
                'data' => new AttendanceResource($attendance),
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json([
                'success' => false,
                'type' => 'error',
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    public function checkInByFace(VerifyFaceRequest $request): JsonResponse
    {
        try {
            $embedding = $request->validated('embedding');
            $faceImage = $request->validated('face_image');
            $matchResult = $this->faceService->matchEmbedding($embedding);

            if (!$matchResult['matched']) {
                return response()->json([
                    'success' => false,
                    'type' => 'error',
                    'message' => 'Face not matched',
                    'data' => $matchResult,
                ], 404);
            }

            $employeeId = $matchResult['employee_id'];
            $todayAttendance = $this->repository->findTodayForEmployee($employeeId);

            if ($todayAttendance && $todayAttendance->check_in_at) {
                return response()->json([
                    'success' => false,
                    'type' => 'error',
                    'message' => 'Already checked in',
                    'data' => [
                        'employee_id' => $employeeId,
                        'employee_name' => $matchResult['employee_name'],
                        'employee_code' => $matchResult['employee_code'],
                        'confidence' => $matchResult['confidence'],
                        'check_in_time' => $todayAttendance->check_in_at,
                    ],
                ], 422);
            }

            $auth = auth('supervisor');
            $supervisor = $auth->user();
            $data = [
                'employee_id' => $employeeId,
                'site_id' => $supervisor?->site_id ?? 1,
                'supervisor_id' => $auth->id(),
                'face_image' => $faceImage,
                'latitude' => $request->validated('latitude'),
                'longitude' => $request->validated('longitude'),
                'device_id' => $request->validated('device_id'),
            ];

            $attendance = $this->attendanceService->checkInByMatchedFace($data, $matchResult['confidence']);

            return response()->json([
                'success' => true,
                'type' => 'success',
                'message' => 'Check-in successful',
                'data' => [
                    'attendance' => new AttendanceResource($attendance),
                    'employee_name' => $matchResult['employee_name'],
                    'employee_code' => $matchResult['employee_code'],
                    'confidence' => $matchResult['confidence'],
                ],
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json([
                'success' => false,
                'type' => 'error',
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    public function checkOutByFace(VerifyFaceRequest $request): JsonResponse
    {
        try {
            $embedding = $request->validated('embedding');
            $faceImage = $request->validated('face_image');
            $matchResult = $this->faceService->matchEmbedding($embedding);

            if (!$matchResult['matched']) {
                return response()->json([
                    'success' => false,
                    'type' => 'error',
                    'message' => 'Face not matched',
                    'data' => $matchResult,
                ], 404);
            }

            $employeeId = $matchResult['employee_id'];
            $todayAttendance = $this->repository->findTodayForEmployee($employeeId);

            if (!$todayAttendance || !$todayAttendance->check_in_at) {
                return response()->json([
                    'success' => false,
                    'type' => 'error',
                    'message' => 'Employee must check in first',
                    'data' => [
                        'employee_id' => $employeeId,
                        'employee_name' => $matchResult['employee_name'],
                        'employee_code' => $matchResult['employee_code'],
                        'confidence' => $matchResult['confidence'],
                    ],
                ], 422);
            }

            if ($todayAttendance->check_out_at) {
                return response()->json([
                    'success' => false,
                    'type' => 'error',
                    'message' => 'Already checked out',
                    'data' => [
                        'employee_id' => $employeeId,
                        'employee_name' => $matchResult['employee_name'],
                        'employee_code' => $matchResult['employee_code'],
                        'confidence' => $matchResult['confidence'],
                        'check_out_time' => $todayAttendance->check_out_at,
                    ],
                ], 422);
            }

            $auth = auth('supervisor');
            $data = [
                'employee_id' => $employeeId,
                'supervisor_id' => $auth->id(),
                'face_image' => $faceImage,
                'latitude' => $request->validated('latitude'),
                'longitude' => $request->validated('longitude'),
                'device_id' => $request->validated('device_id'),
            ];

            $attendance = $this->attendanceService->checkOutByMatchedFace($data, $matchResult['confidence']);

            return response()->json([
                'success' => true,
                'type' => 'success',
                'message' => 'Check-out successful',
                'data' => [
                    'attendance' => new AttendanceResource($attendance),
                    'employee_name' => $matchResult['employee_name'],
                    'employee_code' => $matchResult['employee_code'],
                    'confidence' => $matchResult['confidence'],
                ],
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json([
                'success' => false,
                'type' => 'error',
                'message' => $e->getMessage(),
            ], 422);
        }
    }
}
