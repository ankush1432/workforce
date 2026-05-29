<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'role' => $this->role?->value,
            'company_id' => $this->company_id,
            'phone' => $this->phone,
            'is_active' => $this->is_active,
            'company' => new CompanyResource($this->whenLoaded('company')),
        ];
    }
}
