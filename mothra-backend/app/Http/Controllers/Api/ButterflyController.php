<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Butterfly\StoreButterflyRequest;
use App\Http\Resources\ButterflyResource;
use App\Models\Butterfly;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ButterflyController extends Controller
{
    public function index(): JsonResponse
    {
        $butterflies = Butterfly::all();
        return response()->json([
            'success' => true,
            'data' => ButterflyResource::collection($butterflies),
        ]);
    }

    public function show(Butterfly $butterfly): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => new ButterflyResource($butterfly),
        ]);
    }

    public function store(StoreButterflyRequest $request): JsonResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image_url')) {
            $data['image_url'] = $request->file('image_url')->store('butterflies', 'public');
        }

        $butterfly = Butterfly::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Spesies berhasil ditambahkan',
            'data' => new ButterflyResource($butterfly),
        ], 201);
    }

    public function update(StoreButterflyRequest $request, Butterfly $butterfly): JsonResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image_url')) {
            if ($butterfly->image_url) {
                Storage::disk('public')->delete($butterfly->image_url);
            }
            $data['image_url'] = $request->file('image_url')->store('butterflies', 'public');
        }

        $butterfly->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Spesies berhasil diupdate',
            'data' => new ButterflyResource($butterfly),
        ]);
    }

    public function destroy(Butterfly $butterfly): JsonResponse
    {
        if ($butterfly->image_url) {
            Storage::disk('public')->delete($butterfly->image_url);
        }
        
        $butterfly->delete();

        return response()->json([
            'success' => true,
            'message' => 'Spesies berhasil dihapus',
        ]);
    }
}
