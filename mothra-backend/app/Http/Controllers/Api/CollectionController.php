<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ButterflyResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CollectionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        // Ambil semua spesies yang sudah masuk koleksi user
        $collections = $user->collectedButterflies()->get();

        // Ambil gambar scan terbaru per spesies dari scan_results milik user
        $scanImages = $user->scanResults()
            ->where('is_saved', true)
            ->whereNotNull('butterfly_id')
            ->latest('scanned_at')
            ->get()
            ->unique('butterfly_id')
            ->mapWithKeys(function ($scan) {
                return [
                    $scan->butterfly_id => $scan->image_path,
                ];
            });

        // Sisipkan image_path dari scan_result ke masing-masing butterfly
        $collections->each(function ($butterfly) use ($scanImages) {
            $butterfly->collection_image_path = $scanImages[$butterfly->id] ?? null;
        });

        return response()->json([
            'success' => true,
            'data' => ButterflyResource::collection($collections),
        ]);
    }
}
