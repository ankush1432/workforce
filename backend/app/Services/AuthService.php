<?php

namespace App\Services;

use App\Enums\UserRole;
use App\Models\Supervisor;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use InvalidArgumentException;

class AuthService
{
    public function adminLogin(string $email, string $password): array
    {
        if (! $token = auth('api')->attempt(['email' => $email, 'password' => $password])) {
            throw new InvalidArgumentException('Invalid credentials');
        }

        /** @var User $user */
        $user = auth('api')->user();

        if (! $user->is_active) {
            auth('api')->logout();
            throw new InvalidArgumentException('Account deactivated');
        }

        if (! $user->role?->canAccessAdmin()) {
            auth('api')->logout();
            throw new InvalidArgumentException('Unauthorized for admin panel');
        }

        $user->update(['last_login_at' => now()]);

        return ['token' => $token, 'user' => $user->load('company')];
    }

    public function supervisorLogin(string $email, string $password): array
    {
        if (! $token = auth('supervisor')->attempt(['email' => $email, 'password' => $password])) {
            throw new InvalidArgumentException('Invalid credentials');
        }

        /** @var Supervisor $supervisor */
        $supervisor = auth('supervisor')->user();

        if (! $supervisor->is_active) {
            auth('supervisor')->logout();
            throw new InvalidArgumentException('Account deactivated');
        }

        $supervisor->update(['last_login_at' => now()]);

        return ['token' => $token, 'supervisor' => $supervisor->load(['company', 'site'])];
    }

    public function me(): User|Supervisor
    {
        if (Auth::guard('supervisor')->check()) {
            return Auth::guard('supervisor')->user()->load(['company', 'site']);
        }

        return Auth::guard('api')->user()->load('company');
    }
}
