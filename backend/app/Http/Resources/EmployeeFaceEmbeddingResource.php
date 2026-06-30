<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class EmployeeFaceEmbeddingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'employee_id' => $this->employee_id,
            'model_version' => $this->model_version,
            'quality_score' => $this->quality_score,
            'registered_at' => $this->registered_at?->toIso8601String(),
            'is_primary' => $this->is_primary,
            'face_image_url' => $this->face_image_path ? Storage::disk('public')->url($this->face_image_path) : null,
            'employee' => [
                'id' => $this->employee->id,
                'employee_code' => $this->employee->employee_code,
                'first_name' => $this->employee->first_name,
                'last_name' => $this->employee->last_name,
                'department_relation' => [
                    'name' => $this->employee->department?->name,
                ],
                'designation_relation' => [
                    'name' => $this->employee->designation?->name,
                ],
                'supervisor' => $this->employee->supervisor ? [
                    'first_name' => $this->employee->supervisor->first_name,
                    'last_name' => $this->employee->supervisor->last_name,
                ] : null,
            ],
        ];
    }
}
