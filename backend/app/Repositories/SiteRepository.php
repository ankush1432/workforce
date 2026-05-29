<?php

namespace App\Repositories;

use App\Models\Site;
use Illuminate\Database\Eloquent\Builder;

class SiteRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Site);
    }

    protected function applyFilters(Builder $query, array $filters): Builder
    {
        return parent::applyFilters($query, $filters)->with('company');
    }

    protected function applySearch(Builder $query, string $search): void
    {
        $query->where(function (Builder $q) use ($search) {
            $q->where('name', 'like', "%{$search}%")->orWhere('code', 'like', "%{$search}%");
        });
    }
}
