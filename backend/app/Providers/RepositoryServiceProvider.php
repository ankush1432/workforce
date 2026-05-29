<?php

namespace App\Providers;

use App\Repositories\AttendanceRepository;
use App\Repositories\CompanyRepository;
use App\Repositories\EmployeeRepository;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(CompanyRepository::class);
        $this->app->singleton(EmployeeRepository::class);
        $this->app->singleton(AttendanceRepository::class);
    }
}
