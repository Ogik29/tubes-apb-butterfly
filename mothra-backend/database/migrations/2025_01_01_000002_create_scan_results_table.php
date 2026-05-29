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
        Schema::create('scan_results', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('butterfly_id')->nullable()->constrained('butterflies')->nullOnDelete();
            $table->string('image_path');                        // Path file gambar yang diupload
            $table->string('predicted_species');                 // Nama spesies hasil prediksi CNN
            $table->boolean('is_toxic')->default(false);
            $table->decimal('confidence', 5, 4)->default(0);    // 0.0000 - 1.0000
            $table->boolean('is_saved')->default(false);         // Apakah user menyimpan ke koleksi
            $table->timestamp('scanned_at')->useCurrent();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('scan_results');
    }
};
