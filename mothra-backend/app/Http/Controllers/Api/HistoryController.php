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

        $scanResult->delete();

        return response()->json([
            'success' => true,
            'message' => 'Riwayat dihapus',
        ]);
    }
}
