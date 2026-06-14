<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ScanResultResource;
use App\Models\ScanResult;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HistoryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $history = $request->user()
            ->scanResults()
            ->with('butterfly')
            ->orderBy('scanned_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => ScanResultResource::collection($history),
        ]);
    }

    public function show(Request $request, ScanResult $scanResult): JsonResponse
    {
        if ($scanResult->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $scanResult->load('butterfly');

        return response()->json([
            'success' => true,
            'data' => new ScanResultResource($scanResult),
        ]);
    }

    public function destroy(Request $request, ScanResult $scanResult): JsonResponse
    {
        if ($scanResult->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $butterflyId = $scanResult->butterfly_id;
        $wasSaved = $scanResult->is_saved;

        $scanResult->delete();

        if ($butterflyId) {
            // Jika yang dihapus adalah scan yang disimpan, jadikan scan lain dari spesies ini sebagai saved
            if ($wasSaved) {
                $nextScan = ScanResult::where('user_id', $request->user()->id)
                    ->where('butterfly_id', $butterflyId)
                    ->latest('scanned_at')
                    ->first();

                if ($nextScan) {
                    $nextScan->update(['is_saved' => true]);
                } else {
                    // Jika tidak ada scan lain untuk spesies ini, hapus dari koleksi
                    $request->user()->collectedButterflies()->detach($butterflyId);
                }
            } else {
                // Jika tidak ada scan sama sekali (baik saved maupun unsaved) untuk spesies ini, hapus dari koleksi
                $hasAny = ScanResult::where('user_id', $request->user()->id)
                    ->where('butterfly_id', $butterflyId)
                    ->exists();
                if (!$hasAny) {
                    $request->user()->collectedButterflies()->detach($butterflyId);
                }
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Riwayat dihapus',
        ]);
    }
}
