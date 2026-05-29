<?php

namespace App\Http\Requests\Face;

use Illuminate\Foundation\Http\FormRequest;

class RegisterFaceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'embedding' => ['required', 'array', 'min:128'],
            'embedding.*' => ['numeric'],
            'quality_score' => ['nullable', 'numeric', 'between:0,1'],
        ];
    }
}
