<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ScanResultResource;
use App\Models\Butterfly;
use App\Models\ScanResult;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ScanController extends Controller
{
    public function scan(Request $request): JsonResponse
    {
        $request->validate([
            'image' => 'required|image|max:4096',
        ]);

        $imagePath = $request->file('image')->store('scans', 'public');

        // TODO: Nanti integrasikan dengan model AI Python.
        // Simulasi hasil CNN untuk sementara (seperti di frontend Flutter)
        $butterflies = Butterfly::inRandomOrder()->take(1)->get();
        $isToxic = (bool) rand(0, 1);
        $predictedSpecies = 'Unknown Species';
        $butterflyId = null;

        if ($butterflies->count() > 0) {
            $butterfly = $butterflies->first();
            $predictedSpecies = $butterfly->name;
            $isToxic = $butterfly->is_toxic;
            $butterflyId = $butterfly->id;
        }

        $scanResult = ScanResult::create([
            'user_id' => $request->user()->id,
            'butterfly_id' => $butterflyId,
            'image_path' => $imagePath,
            'predicted_species' => $predictedSpecies,
            'is_toxic' => $isToxic,
            'confidence' => (float) (rand(6000, 9900) / 10000), // 0.6000 to 0.9900
            'is_saved' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Scan berhasil',
            'data' => new ScanResultResource($scanResult),
        ]);
    }

    public function saveScan(Request $request, ScanResult $scanResult): JsonResponse
    {
        // Pastikan milik user yang login
        if ($scanResult->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $scanResult->update(['is_saved' => true]);

        // Jika berhasil diidentifikasi, tambahkan ke koleksi
        if ($scanResult->butterfly_id) {
            $request->user()->collectedButterflies()->syncWithoutDetaching([
                $scanResult->butterfly_id => ['first_scanned_at' => now()]
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Hasil scan disimpan ke koleksi',
            'data' => new ScanResultResource($scanResult),
        ]);
    }
}
