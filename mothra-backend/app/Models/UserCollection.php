<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserCollection extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'butterfly_id',
        'first_scanned_at',
    ];

    protected $casts = [
        'first_scanned_at' => 'datetime',
    ];

    /**
     * User pemilik koleksi ini
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Spesies kupu-kupu yang dikoleksi
     */
    public function butterfly(): BelongsTo
    {
        return $this->belongsTo(Butterfly::class);
    }
}
