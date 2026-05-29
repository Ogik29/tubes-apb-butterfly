<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ButterflyResource extends JsonResource
{
    /**
     * Response kupu-kupu sesuai dengan ButterflyModel di Flutter.
     * Tambahan: is_collected (apakah user yang request sudah pernah scan ini)
     */
    public function toArray(Request $request): array
    {
        // is_collected hanya bisa dihitung jika ada user yang login
        $isCollected = false;
        if ($request->user()) {
            $isCollected = $request->user()
                ->collections()
                ->where('butterfly_id', $this->id)
                ->exists();
        }

        return [
            'id'                  => $this->id,
            'name'                => $this->name,
            'scientific_name'     => $this->scientific_name,
            'is_toxic'            => $this->is_toxic,
            'description'         => $this->description,
            'image_url'           => $this->image_url
                                        ? asset('storage/' . $this->image_url)
                                        : null,
            'is_collected'        => $isCollected,
            'habitat'             => $this->habitat,
            'distribution'        => $this->distribution,
            'wing_span'           => $this->wing_span,
            'toxin_type'          => $this->toxin_type,
            'safety_advice'       => $this->safety_advice,
            'conservation_status' => $this->conservation_status,
            'diet'                => $this->diet,
            'created_at'          => $this->created_at->toIso8601String(),
            'updated_at'          => $this->updated_at->toIso8601String(),
        ];
    }
}
