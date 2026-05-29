<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Face\RegisterFaceRequest;
use App\Http\Requests\Face\VerifyFaceRequest;
use App\Http\Resources\EmployeeFaceEmbeddingResource;
use App\Http\Resources\EmployeeResource;
use App\Repositories\EmployeeRepository;
use App\Services\FaceEmbeddingService;
use Illuminate\Http\JsonResponse;

class FaceRegistrationController extends Controller
{
    public function __construct(
        private readonly FaceEmbeddingService $faceService,
        private readonly EmployeeRepository $employeeRepository,
    ) {}

    public function status(int $employeeId): JsonResponse
    {
        $employee = $this->employeeRepository->find($employeeId);
        abort_if(! $employee, 404);

        $status = $this->faceService->getStatus($employeeId);

        return response()->json([
            'data' => array_merge($status, [
                'employee' => new EmployeeResource($employee->load(['company', 'site'])),
            ]),
        ]);
    }

    public function register(RegisterFaceRequest $request, int $employeeId): JsonResponse
    {
        $supervisorId = auth('supervisor')->id();

        $embedding = $this->faceService->register(
            $employeeId,
            $request->validated('embedding'),
            $supervisorId,
            $request->validated('quality_score')
        );

        $employee = $this->employeeRepository->find($employeeId);
        $status = $this->faceService->getStatus($employeeId);

        return response()->json([
            'message' => 'Face registered successfully',
            'data' => [
                'embedding' => new EmployeeFaceEmbeddingResource($embedding),
                'registration_status' => $status['registration_status'],
                'embedding_exists' => $status['embedding_exists'],
                'face_registered' => $status['face_registered'],
                'confidence' => $status['confidence'],
                'employee' => new EmployeeResource($employee->load(['company', 'site'])),
            ],
        ], 201);
    }

    public function verify(VerifyFaceRequest $request, int $employeeId): JsonResponse
    {
        $result = $this->faceService->verify($employeeId, $request->validated('embedding'));

        return response()->json(['data' => $result]);
    }
}
