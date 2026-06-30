<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EmployeeFaceEmbedding extends Model
{
    protected $fillable = [
        'employee_id', 'embedding', 'face_image_path', 'model_version', 'quality_score',
        'registered_by_supervisor_id', 'registered_at', 'is_primary',
    ];

    protected function casts(): array
    {
        return [
            'embedding' => 'array',
            'quality_score' => 'decimal:4',
            'registered_at' => 'datetime',
            'is_primary' => 'boolean',
        ];
    }

    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class);
    }

    public function registeredBy(): BelongsTo
    {
        return $this->belongsTo(Supervisor::class, 'registered_by_supervisor_id');
    }
}
