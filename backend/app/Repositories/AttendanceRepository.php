<?php

namespace App\Repositories;

use App\Models\Attendance;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;

class AttendanceRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Attendance);
    }

    protected function applyFilters(Builder $query, array $filters): Builder
    {
        $query = parent::applyFilters($query, $filters);

        if (! empty($filters['employee_id'])) {
            $query->where('employee_id', $filters['employee_id']);
        }

        if (! empty($filters['date_from'])) {
            $query->whereDate('attendance_date', '>=', $filters['date_from']);
        }

        if (! empty($filters['date_to'])) {
            $query->whereDate('attendance_date', '<=', $filters['date_to']);
        }

        if (! empty($filters['attendance_date'])) {
            $query->whereDate('attendance_date', $filters['attendance_date']);
        }

        return $query->with(['employee', 'site', 'shift', 'supervisor']);
    }

    public function findTodayForEmployee(int $employeeId): ?Attendance
    {
        return $this->query()
            ->where('employee_id', $employeeId)
            ->whereDate('attendance_date', Carbon::today())
            ->first();
    }
}
