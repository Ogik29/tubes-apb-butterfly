<?php

namespace App\Http\Requests\Butterfly;

use Illuminate\Foundation\Http\FormRequest;

class StoreButterflyRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && $this->user()->isAdmin();
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'scientific_name' => ['required', 'string', 'max:255'],
            'is_toxic' => ['boolean'],
            'description' => ['required', 'string'],
            'image_url' => ['nullable', 'image', 'max:2048'], // validasi image
            'habitat' => ['nullable', 'string', 'max:255'],
            'distribution' => ['nullable', 'string', 'max:255'],
            'wing_span' => ['nullable', 'string', 'max:255'],
            'toxin_type' => ['nullable', 'string', 'max:255'],
            'safety_advice' => ['nullable', 'string'],
            'conservation_status' => ['nullable', 'string', 'max:255'],
            'diet' => ['nullable', 'string'],
        ];
    }
}
