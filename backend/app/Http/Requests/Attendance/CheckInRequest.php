<?php

namespace App\Http\Requests\Attendance;

use Illuminate\Foundation\Http\FormRequest;

class CheckInRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'employee_id' => ['required', 'exists:employees,id'],
            'site_id' => ['required', 'exists:sites,id'],
            'shift_id' => ['nullable', 'exists:shifts,id'],
            'embedding' => ['required', 'array', 'min:128'],
            'embedding.*' => ['numeric'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'device_id' => ['nullable', 'string', 'max:100'],
        ];
    }
}
