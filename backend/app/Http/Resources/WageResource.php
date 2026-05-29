<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'employee_id' => $this->employee_id,
            'year' => $this->year,
            'month' => $this->month,
            'hourly_rate' => $this->hourly_rate,
            'daily_rate' => $this->daily_rate,
            'days_worked' => $this->days_worked,
            'hours_worked' => $this->hours_worked,
            'gross_amount' => $this->gross_amount,
            'deductions' => $this->deductions,
            'net_amount' => $this->net_amount,
            'status' => $this->status,
            'employee' => new EmployeeResource($this->whenLoaded('employee')),
        ];
    }
}
