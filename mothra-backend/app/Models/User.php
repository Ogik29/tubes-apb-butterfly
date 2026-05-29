<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'avatar_url',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    /**
     * Cek apakah user adalah admin
     */
    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    /**
     * Riwayat scan milik user ini
     */
    public function scanResults(): HasMany
    {
        return $this->hasMany(ScanResult::class);
    }

    /**
     * Koleksi kupu-kupu yang sudah ditemukan user ini
     */
    public function collections(): HasMany
    {
        return $this->hasMany(UserCollection::class);
    }

    /**
     * Spesies yang sudah ditemukan (via pivot)
     */
    public function collectedButterflies(): BelongsToMany
    {
        return $this->belongsToMany(Butterfly::class, 'user_collections')
                    ->withTimestamps()
                    ->withPivot('first_scanned_at');
    }
}
