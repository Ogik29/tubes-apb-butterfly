<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ScanResultResource extends JsonResource
{
    /**
     * Response hasil scan sesuai dengan ScanResultModel di Flutter.
     */
    public function toArray(Request $request): array
    {
        return [
            'id'                => $this->id,
            'user_id'           => $this->user_id,
            'butterfly_id'      => $this->butterfly_id,
            'image_path'        => $this->image_path
                                      ? asset('storage/' . $this->image_path)
                                      : '',
            'predicted_species' => $this->predicted_species,
            'is_toxic'          => $this->is_toxic,
            'confidence'        => $this->confidence,
            'confidence_percent'=> $this->confidence_percent, // accessor "94.7%"
            'is_saved'          => $this->is_saved,
            'scanned_at'        => $this->scanned_at ? $this->scanned_at->toIso8601String() : now()->toIso8601String(),
            // Relasi butterfly (jika loaded)
            'butterfly'         => $this->whenLoaded('butterfly', function () {
                return new ButterflyResource($this->butterfly);
            }),
        ];
    }
}
