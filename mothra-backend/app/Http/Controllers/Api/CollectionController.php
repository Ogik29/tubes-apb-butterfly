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
        $collections = $request->user()->collectedButterflies()->get();

        return response()->json([
            'success' => true,
            'data' => ButterflyResource::collection($collections),
        ]);
    }
}
