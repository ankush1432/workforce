<?php

namespace App\Repositories;

use App\Models\Shift;
use Illuminate\Database\Eloquent\Builder;

class ShiftRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Shift);
    }

    protected function applyFilters(Builder $query, array $filters): Builder
    {
        return parent::applyFilters($query, $filters);
    }
}
