<?php

namespace App\Services;

use App\Models\Attendance;
use App\Models\Employee;
use App\Models\Site;
use App\Models\Supervisor;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardService
{
    public function adminStats(?int $companyId = null): array
    {
        $today = Carbon::today();

        $employeeQuery = Employee::query()->where('is_active', true);
        $attendanceQuery = Attendance::query()->whereDate('attendance_date', $today);

        if ($companyId) {
            $employeeQuery->where('company_id', $companyId);
            $attendanceQuery->whereHas('employee', fn ($q) => $q->where('company_id', $companyId));
        }

        $totalEmployees = (clone $employeeQuery)->count();
        $presentToday = (clone $attendanceQuery)->whereNotNull('check_in_at')->count();
        $faceRegistered = (clone $employeeQuery)->where('face_registered', true)->count();

        $siteQuery = Site::query()->where('is_active', true);
        if ($companyId) {
            $siteQuery->where('company_id', $companyId);
        }

        return [
            'sites' => $siteQuery->count(),
            'employees' => $totalEmployees,
            'supervisors' => $companyId
                ? Supervisor::where('company_id', $companyId)->where('is_active', true)->count()
                : Supervisor::where('is_active', true)->count(),
            'present_today' => $presentToday,
            'absent_today' => max(0, $totalEmployees - $presentToday),
            'face_registered' => $faceRegistered,
            'face_pending' => max(0, $totalEmployees - $faceRegistered),
            'attendance_rate' => $totalEmployees > 0
                ? round(($presentToday / $totalEmployees) * 100, 1)
                : 0,
            'weekly_trend' => $this->weeklyTrend($companyId),
        ];
    }

    private function weeklyTrend(?int $companyId): array
    {
        $start = Carbon::today()->subDays(6);

        $query = Attendance::query()
            ->select(DB::raw('DATE(attendance_date) as date'), DB::raw('COUNT(*) as count'))
            ->whereDate('attendance_date', '>=', $start)
            ->whereNotNull('check_in_at')
            ->groupBy('date')
            ->orderBy('date');

        if ($companyId) {
            $query->whereHas('employee', fn ($q) => $q->where('company_id', $companyId));
        }

        return $query->get()->map(fn ($row) => [
            'date' => $row->date,
            'count' => (int) $row->count,
        ])->values()->all();
    }
}
