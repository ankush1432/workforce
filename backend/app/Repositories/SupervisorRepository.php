<?php

namespace App\Repositories;

use App\Models\Supervisor;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Hash;

class SupervisorRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Supervisor);
    }

    protected function applyFilters(Builder $query, array $filters): Builder
    {
        return parent::applyFilters($query, $filters)->with(['company', 'site']);
    }

    public function create(array $data): Supervisor
    {
        if (! empty($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        }

        return parent::create($data);
    }

    public function update(int $id, array $data): Supervisor
    {
        if (! empty($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        } else {
            unset($data['password']);
        }

        return parent::update($id, $data);
    }

    protected function applySearch(Builder $query, string $search): void
    {
        $query->where(function (Builder $q) use ($search) {
            $q->where('first_name', 'like', "%{$search}%")
                ->orWhere('last_name', 'like', "%{$search}%")
                ->orWhere('email', 'like', "%{$search}%")
                ->orWhere('employee_code', 'like', "%{$search}%");
        });
    }
}
