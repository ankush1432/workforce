<?php

use App\Http\Controllers\Api\V1\AttendanceController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CompanyController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\EmployeeController;
use App\Http\Controllers\Api\V1\EventController;
use App\Http\Controllers\Api\V1\FaceRegistrationController;
use App\Http\Controllers\Api\V1\OfflineSyncController;
use App\Http\Controllers\Api\V1\ShiftController;
use App\Http\Controllers\Api\V1\SiteController;
use App\Http\Controllers\Api\V1\SupervisorController;
use App\Http\Controllers\Api\V1\WageController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('auth/admin/login', [AuthController::class, 'adminLogin']);
    Route::post('auth/supervisor/login', [AuthController::class, 'supervisorLogin']);

    Route::middleware('auth:api')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/me', [AuthController::class, 'me']);
        Route::get('dashboard', [DashboardController::class, 'index']);

        Route::apiResource('companies', CompanyController::class);
        Route::apiResource('sites', SiteController::class);
        Route::apiResource('supervisors', SupervisorController::class);
        Route::apiResource('employees', EmployeeController::class);
        Route::apiResource('shifts', ShiftController::class);
        Route::apiResource('wages', WageController::class);
        Route::get('attendance', [AttendanceController::class, 'index']);
        Route::apiResource('events', EventController::class);
        Route::post('events/{id}/publish', [EventController::class, 'publish']);
        Route::post('events/{id}/unpublish', [EventController::class, 'unpublish']);
    });

    Route::middleware('auth:supervisor')->prefix('supervisor')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/me', [AuthController::class, 'me']);
        Route::get('dashboard', [DashboardController::class, 'index']);
        Route::get('employees', [EmployeeController::class, 'index']);
        Route::get('employees/{id}', [EmployeeController::class, 'show']);

        Route::get('employees/{employeeId}/face/status', [FaceRegistrationController::class, 'status']);
        Route::post('employees/{employeeId}/face/register', [FaceRegistrationController::class, 'register']);
        Route::post('employees/{employeeId}/face/verify', [FaceRegistrationController::class, 'verify']);

        Route::post('attendance/check-in', [AttendanceController::class, 'checkIn']);
        Route::post('attendance/check-out', [AttendanceController::class, 'checkOut']);
        Route::get('attendance', [AttendanceController::class, 'index']);
        Route::get('employees/{employeeId}/attendance/today', [AttendanceController::class, 'todayForEmployee']);

        Route::get('events', [EventController::class, 'index']);
        Route::get('events/{id}', [EventController::class, 'show']);

        Route::post('offline/sync', [OfflineSyncController::class, 'sync']);
    });
});
