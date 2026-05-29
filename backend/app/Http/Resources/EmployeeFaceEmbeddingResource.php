<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

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
        ];
    }
}
