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

        // Jika data berasal dari halaman koleksi, pakai gambar dari scan_results.
        // Kalau tidak ada, fallback ke butterflies.image_url.
        $displayImagePath = $this->collection_image_path ?? $this->image_url;

        return [
            'id'                  => $this->id,
            'name'                => $this->name,
            'scientific_name'     => $this->scientific_name,
            'is_toxic'            => $this->is_toxic,
            'description'         => $this->description,
            'image_url'           => $displayImagePath
                ? request()->getSchemeAndHttpHost() . '/storage/' . ltrim($displayImagePath, '/')
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
