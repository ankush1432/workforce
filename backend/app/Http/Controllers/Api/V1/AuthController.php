<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\AdminLoginRequest;
use App\Http\Requests\Auth\SupervisorLoginRequest;
use App\Http\Resources\UserResource;
use App\Http\Resources\SupervisorResource;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use InvalidArgumentException;

class AuthController extends Controller
{
    public function __construct(private readonly AuthService $authService) {}

    public function adminLogin(AdminLoginRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->adminLogin(
                $request->validated('email'),
                $request->validated('password')
            );

            return response()->json([
                'token' => $result['token'],
                'token_type' => 'bearer',
                'expires_in' => auth('api')->factory()->getTTL() * 60,
                'user' => new UserResource($result['user']),
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 401);
        }
    }

    public function supervisorLogin(SupervisorLoginRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->supervisorLogin(
                $request->validated('email'),
                $request->validated('password')
            );

            return response()->json([
                'token' => $result['token'],
                'token_type' => 'bearer',
                'expires_in' => auth('supervisor')->factory()->getTTL() * 60,
                'supervisor' => new SupervisorResource($result['supervisor']),
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 401);
        }
    }

    public function me(): JsonResponse
    {
        $user = $this->authService->me();

        if ($user instanceof \App\Models\Supervisor) {
            return response()->json(['supervisor' => new SupervisorResource($user)]);
        }

        return response()->json(['user' => new UserResource($user)]);
    }

    public function logout(): JsonResponse
    {
        if (auth('supervisor')->check()) {
            auth('supervisor')->logout();
        } else {
            auth('api')->logout();
        }

        return response()->json(['message' => 'Logged out']);
    }
}
