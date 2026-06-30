<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Employee extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'company_id', 'site_id', 'department_id', 'designation_id', 'shift_id', 'supervisor_id',
        'employee_code', 'first_name', 'last_name', 'email', 'phone',
        'department', 'designation', 'date_of_joining', 'face_registered', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'date_of_joining' => 'date',
            'face_registered' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function site(): BelongsTo
    {
        return $this->belongsTo(Site::class);
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function designation(): BelongsTo
    {
        return $this->belongsTo(Designation::class);
    }

    public function shift(): BelongsTo
    {
        return $this->belongsTo(Shift::class);
    }

    public function supervisor(): BelongsTo
    {
        return $this->belongsTo(Supervisor::class);
    }

    public function faceEmbeddings(): HasMany
    {
        return $this->hasMany(EmployeeFaceEmbedding::class);
    }

    public function primaryEmbedding(): HasOne
    {
        return $this->hasOne(EmployeeFaceEmbedding::class)->where('is_primary', true);
    }

    public function attendances(): HasMany
    {
        return $this->hasMany(Attendance::class);
    }

    public function wages(): HasMany
    {
        return $this->hasMany(Wage::class);
    }

    public function getFullNameAttribute(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }
}
