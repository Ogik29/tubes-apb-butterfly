<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ScanResult extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'butterfly_id',
        'image_path',
        'predicted_species',
        'is_toxic',
        'confidence',
        'toxicity_confidence',
        'is_saved',
        'scanned_at',
    ];

    protected $casts = [
        'is_toxic'            => 'boolean',
        'is_saved'            => 'boolean',
        'confidence'          => 'float',
        'toxicity_confidence' => 'float',
        'scanned_at'          => 'datetime',
    ];

    /**
     * User pemilik scan ini
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Spesies kupu-kupu yang diidentifikasi (nullable jika tidak dikenali)
     */
    public function butterfly(): BelongsTo
    {
        return $this->belongsTo(Butterfly::class);
    }

    /**
     * Accessor: confidence dalam persen string
     */
    public function getConfidencePercentAttribute(): string
    {
        return number_format($this->confidence * 100, 1) . '%';
    }
}
