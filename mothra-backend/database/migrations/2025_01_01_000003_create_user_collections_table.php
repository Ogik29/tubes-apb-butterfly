<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('user_collections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('butterfly_id')->constrained('butterflies')->cascadeOnDelete();
            $table->timestamp('first_scanned_at')->useCurrent(); // Kapan pertama kali ditemukan
            $table->timestamps();

            // Satu spesies hanya bisa ada sekali per user
            $table->unique(['user_id', 'butterfly_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_collections');
    }
};
