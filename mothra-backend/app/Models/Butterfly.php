<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Butterfly extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'scientific_name',
        'is_toxic',
        'description',
        'image_url',
        'habitat',
        'distribution',
        'wing_span',
        'toxin_type',
        'safety_advice',
        'conservation_status',
        'diet',
    ];

    protected $casts = [
        'is_toxic' => 'boolean',
    ];

    /**
     * Semua hasil scan yang merujuk ke spesies ini
     */
    public function scanResults(): HasMany
    {
        return $this->hasMany(ScanResult::class);
    }

    /**
     * User yang sudah mengoleksi spesies ini
     */
    public function collectedByUsers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_collections')
                    ->withTimestamps()
                    ->withPivot('first_scanned_at');
    }
}
