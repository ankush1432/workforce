<?php

namespace App\Enums;

enum UserRole: string
{
    case SuperAdmin = 'super_admin';
    case Admin = 'admin';
    case Supervisor = 'supervisor';

    public function canAccessAdmin(): bool
    {
        return in_array($this, [self::SuperAdmin, self::Admin], true);
    }

    public function permissions(): array
    {
        return match ($this) {
            self::SuperAdmin => ['*'],
            self::Admin => [
                'companies.view', 'companies.manage',
                'sites.view', 'sites.manage',
                'supervisors.view', 'supervisors.manage',
                'employees.view', 'employees.manage',
                'attendance.view', 'attendance.manage',
                'shifts.view', 'shifts.manage',
                'wages.view', 'wages.manage',
                'reports.view', 'notifications.view', 'settings.manage',
            ],
            self::Supervisor => [
                'employees.view', 'attendance.manage', 'face.register',
            ],
        };
    }
}
