<?php

namespace Database\Seeders;

use App\Enums\UserRole;
use App\Models\Company;
use App\Models\Employee;
use App\Models\Shift;
use App\Models\Site;
use App\Models\Supervisor;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $company = Company::create([
            'name' => 'Acme Corporation',
            'code' => 'ACME',
            'email' => 'hr@acme.com',
            'phone' => '+1-555-0100',
            'address' => '100 Enterprise Blvd',
            'timezone' => 'America/New_York',
            'is_active' => true,
        ]);

        $site = Site::create([
            'company_id' => $company->id,
            'name' => 'Headquarters',
            'code' => 'HQ-01',
            'address' => '100 Enterprise Blvd',
            'latitude' => 40.7128,
            'longitude' => -74.0060,
            'geofence_radius_m' => 150,
            'is_active' => true,
        ]);

        User::create([
            'name' => 'System Admin',
            'email' => 'admin@faceattendance.com',
            'password' => Hash::make('password'),
            'role' => UserRole::SuperAdmin,
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Company Admin',
            'email' => 'company@acme.com',
            'password' => Hash::make('password'),
            'role' => UserRole::Admin,
            'company_id' => $company->id,
            'is_active' => true,
        ]);

        $supervisor = Supervisor::create([
            'company_id' => $company->id,
            'site_id' => $site->id,
            'employee_code' => 'SUP-001',
            'first_name' => 'John',
            'last_name' => 'Supervisor',
            'email' => 'supervisor@acme.com',
            'phone' => '+1-555-0101',
            'password' => Hash::make('password'),
            'is_active' => true,
        ]);

        Shift::create([
            'company_id' => $company->id,
            'site_id' => $site->id,
            'name' => 'General Shift',
            'start_time' => '09:00:00',
            'end_time' => '18:00:00',
            'grace_minutes' => 15,
            'is_active' => true,
        ]);

        for ($i = 1; $i <= 5; $i++) {
            Employee::create([
                'company_id' => $company->id,
                'site_id' => $site->id,
                'employee_code' => sprintf('EMP-%03d', $i),
                'first_name' => "Employee{$i}",
                'last_name' => 'Demo',
                'email' => "emp{$i}@acme.com",
                'department' => 'Operations',
                'designation' => 'Staff',
                'face_registered' => false,
                'is_active' => true,
            ]);
        }

        $this->command?->info('Seeded: admin@faceattendance.com / password');
        $this->command?->info('Seeded: supervisor@acme.com / password');
    }
}
