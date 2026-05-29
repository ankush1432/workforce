<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmployeeResource extends JsonResource
{
    private function resolveFaceRegistrationStatus(): string
    {
        if ($this->face_registered) {
            $hasEmbedding = $this->relationLoaded('primaryEmbedding')
                ? $this->primaryEmbedding !== null
                : $this->faceEmbeddings()->where('is_primary', true)->exists();

            return $hasEmbedding ? 'registered' : 'pending_sync';
        }

        return 'not_registered';
    }

    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'company_id' => $this->company_id,
            'site_id' => $this->site_id,
            'employee_code' => $this->employee_code,
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'full_name' => $this->full_name,
            'email' => $this->email,
            'phone' => $this->phone,
            'department' => $this->department,
            'designation' => $this->designation,
            'date_of_joining' => $this->date_of_joining?->format('Y-m-d'),
            'face_registered' => $this->face_registered,
            'face_registration_status' => $this->resolveFaceRegistrationStatus(),
            'embedding_exists' => $this->relationLoaded('primaryEmbedding')
                ? $this->primaryEmbedding !== null
                : $this->faceEmbeddings()->where('is_primary', true)->exists(),
            'is_active' => $this->is_active,
            'company' => new CompanyResource($this->whenLoaded('company')),
            'site' => new SiteResource($this->whenLoaded('site')),
        ];
    }
}
