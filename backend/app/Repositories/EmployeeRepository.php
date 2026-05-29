<?php

namespace App\Repositories;

use App\Models\Employee;
use Illuminate\Database\Eloquent\Builder;

class EmployeeRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Employee);
    }

    protected function applyFilters(Builder $query, array $filters): Builder
    {
        $query = parent::applyFilters($query, $filters);

        if (isset($filters['face_registered'])) {
            $query->where('face_registered', (bool) $filters['face_registered']);
        }

        return $query->with(['company', 'site', 'primaryEmbedding']);
    }

    protected function applySearch(Builder $query, string $search): void
    {
        $query->where(function (Builder $q) use ($search) {
            $q->where('first_name', 'like', "%{$search}%")
                ->orWhere('last_name', 'like', "%{$search}%")
                ->orWhere('employee_code', 'like', "%{$search}%")
                ->orWhere('email', 'like', "%{$search}%");
        });
    }

    public function findByCode(string $code): ?Employee
    {
        return $this->query()->where('employee_code', $code)->first();
    }
}
