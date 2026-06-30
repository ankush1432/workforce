<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class AttendanceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'employee_id' => $this->employee_id,
            'site_id' => $this->site_id,
            'shift_id' => $this->shift_id,
            'attendance_date' => $this->attendance_date?->format('Y-m-d'),
            'check_in_at' => $this->check_in_at?->toIso8601String(),
            'check_out_at' => $this->check_out_at?->toIso8601String(),
            'check_in_confidence' => $this->check_in_confidence,
            'check_out_confidence' => $this->check_out_confidence,
            'status' => $this->status,
            'worked_minutes' => $this->worked_minutes,
            'checkin_face_image_url' => $this->checkin_face_image ? Storage::disk('public')->url($this->checkin_face_image) : null,
            'checkout_face_image_url' => $this->checkout_face_image ? Storage::disk('public')->url($this->checkout_face_image) : null,
            'employee' => new EmployeeResource($this->whenLoaded('employee')),
            'site' => new SiteResource($this->whenLoaded('site')),
            'shift' => new ShiftResource($this->whenLoaded('shift')),
        ];
    }
}
