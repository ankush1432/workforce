<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AttendanceLog extends Model
{
    protected $fillable = [
        'attendance_id', 'employee_id', 'action', 'logged_at', 'latitude', 'longitude',
        'confidence_score', 'device_id', 'metadata',
    ];

    protected function casts(): array
    {
        return [
            'logged_at' => 'datetime',
            'confidence_score' => 'decimal:4',
            'metadata' => 'array',
        ];
    }

    public function attendance(): BelongsTo
    {
        return $this->belongsTo(Attendance::class);
    }

    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class);
    }
}
