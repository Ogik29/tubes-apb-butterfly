<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin user (email yang dipakai di login Flutter: atmint@gmail.com)
        User::create([
            'name'       => 'Admin',
            'email'      => 'atmint@gmail.com',
            'password'   => Hash::make('password123'),
            'role'       => 'admin',
            'avatar_url' => null,
        ]);

        // User biasa
        User::create([
            'name'       => 'Pengguna',
            'email'      => 'user@gmail.com',
            'password'   => Hash::make('password123'),
            'role'       => 'user',
            'avatar_url' => null,
        ]);
    }
}
