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
        Schema::create('butterflies', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('scientific_name');
            $table->boolean('is_toxic')->default(false);
            $table->text('description');
            $table->string('image_url')->nullable();
            $table->string('habitat')->nullable();
            $table->string('distribution')->nullable();
            $table->string('wing_span')->nullable();           // Contoh: "8–12 cm"
            $table->string('toxin_type')->nullable();          // Jenis racun jika beracun
            $table->text('safety_advice')->nullable();         // Saran keselamatan
            $table->string('conservation_status')->nullable(); // LC, NT, VU, EN, CR
            $table->text('diet')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('butterflies');
    }
};
