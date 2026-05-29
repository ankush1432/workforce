<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Wage extends Model
{
    protected $fillable = [
        'employee_id', 'company_id', 'year', 'month', 'hourly_rate', 'daily_rate',
        'days_worked', 'hours_worked', 'overtime_hours', 'gross_amount',
        'deductions', 'net_amount', 'status',
    ];

    protected function casts(): array
    {
        return [
            'hourly_rate' => 'decimal:2',
            'daily_rate' => 'decimal:2',
            'overtime_hours' => 'decimal:2',
            'gross_amount' => 'decimal:2',
            'deductions' => 'decimal:2',
            'net_amount' => 'decimal:2',
        ];
    }

    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class);
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }
}
