<?php

namespace App\Repositories;

use App\Models\Event;
use Illuminate\Database\Eloquent\Builder;

class EventRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Event);
    }

    protected function applyFilters(Builder $query, array $filters): Builder
    {
        $query = parent::applyFilters($query, $filters);

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (! empty($filters['published_only'])) {
            $query->where('status', 'published');
        }

        return $query->orderByDesc('start_date');
    }
}
