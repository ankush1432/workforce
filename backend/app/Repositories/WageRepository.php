<?php

namespace App\Repositories;

use App\Models\Wage;
use Illuminate\Database\Eloquent\Builder;

class WageRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Wage);
    }

    protected function applyFilters(Builder $query, array $filters): Builder
    {
        $query = parent::applyFilters($query, $filters);

        if (! empty($filters['employee_id'])) {
            $query->where('employee_id', $filters['employee_id']);
        }

        if (! empty($filters['year'])) {
            $query->where('year', $filters['year']);
        }

        if (! empty($filters['month'])) {
            $query->where('month', $filters['month']);
        }

        return $query->with('employee');
    }
}
