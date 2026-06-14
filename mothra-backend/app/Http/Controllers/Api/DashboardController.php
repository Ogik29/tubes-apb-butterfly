<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Butterfly;
use App\Models\ScanResult;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function stats(Request $request): JsonResponse
    {
        $user = $request->user();

        $totalScan = $user->scanResults()->count();

        $collectedSpecies = $user->collectedButterflies()->get();
        $safeButterflies = $collectedSpecies->where('is_toxic', false)->count();
        $toxicFound = $collectedSpecies->where('is_toxic', true)->count();
        $collectedCount = $collectedSpecies->count();
        $totalCount = Butterfly::count();

        $savedScans = $user->scanResults()->where('is_saved', true)->get();

        // Rata-rata keyakinan spesies mencakup semua spesies (beracun & aman)
        $avgConfidence = $savedScans->isEmpty() ? 0 : $savedScans->avg('confidence');

        // Rata-rata keyakinan status racun hanya mencakup kupu-kupu yang beracun saja
        $toxicSavedScans = $savedScans->where('is_toxic', true);
        $avgToxicityConfidence = $toxicSavedScans->isEmpty() ? 0 : $toxicSavedScans->avg('toxicity_confidence');

        return response()->json([
            'success' => true,
            'data' => [
                'total_scans' => $totalScan,
                'safe_butterflies' => $safeButterflies,
                'toxic_found' => $toxicFound,
                'collected_count' => $collectedCount,
                'total_count' => $totalCount,
                'avg_confidence' => (float) $avgConfidence,
                'avg_toxicity_confidence' => (float) $avgToxicityConfidence,
            ]
        ]);
    }

    public function adminStats(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'total_species' => Butterfly::count(),
                'total_users' => User::count(),
                'total_scans' => ScanResult::count(),
                'active_users' => User::where('role', 'user')->count(),
            ]
        ]);
    }
}
