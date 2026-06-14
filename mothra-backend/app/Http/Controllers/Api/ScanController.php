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
    public function scan(Request $request): JsonResponse // ambil prediksi model di predict.py
    {
        $request->validate([
            'image' => 'required|image|max:4096',
        ]);

        $imagePath = $request->file('image')->store('scans', 'public');

        $absoluteImagePath = storage_path('app/public/' . $imagePath);
        $pythonScript = base_path('ml/predict.py');

        // Windows biasanya bisa pakai "python".
        // Kalau pakai venv Windows, bisa ganti ke: base_path('venv/Scripts/python.exe')
        // Kalau Mac/Linux venv: base_path('venv/bin/python')
        $pythonBinary = env('PYTHON_BINARY', 'python');

        // Jika path tidak berupa perintah global ("python"/"python3") dan file-nya ada di dalam base_path(),
        // ubah menjadi absolute path agar eksekusi shell lebih terjamin.
        if ($pythonBinary !== 'python' && $pythonBinary !== 'python3' && file_exists(base_path($pythonBinary))) {
            $pythonBinary = base_path($pythonBinary);
        }

        $command = escapeshellarg($pythonBinary)
            . ' '
            . escapeshellarg($pythonScript)
            . ' '
            . escapeshellarg($absoluteImagePath);

        $output = shell_exec($command . ' 2>&1');

        // Cari posisi awal JSON '{' dan akhir '}' untuk memotong output warning/info TensorFlow
        $startPos = strpos($output, '{');
        $endPos = strrpos($output, '}');
        if ($startPos !== false && $endPos !== false) {
            $jsonString = substr($output, $startPos, $endPos - $startPos + 1);
            $prediction = json_decode($jsonString, true);
        } else {
            $prediction = null;
        }

        if (!$prediction || !isset($prediction['success']) || $prediction['success'] !== true) {
            return response()->json([
                'success' => false,
                'message' => 'Prediksi model gagal',
                'debug_output' => $output,
            ], 500);
        }

        $predictedSpecies = $prediction['species'];
        $confidence = $prediction['confidence'] ?? 0;
        $isToxicFromModel = $prediction['is_toxic'] ?? false;
        $toxicityConfidence = $prediction['toxicity_score'] ?? 0.0;

        $butterfly = Butterfly::whereRaw('LOWER(name) = ?', [
            strtolower(str_replace('_', ' ', $predictedSpecies))
        ])->first();

        $butterflyId = null;
        $isToxic = $isToxicFromModel;

        if ($butterfly) {
            $butterflyId = $butterfly->id;

            // Lebih aman mengikuti data database, karena field is_toxic sudah diatur di seeder.
            $isToxic = $butterfly->is_toxic;
            $predictedSpecies = $butterfly->name;
        }

        $scanResult = ScanResult::create([
            'user_id' => $request->user()->id,
            'butterfly_id' => $butterflyId,
            'image_path' => $imagePath,
            'predicted_species' => $predictedSpecies,
            'is_toxic' => $isToxic,
            'confidence' => $confidence,
            'toxicity_confidence' => $toxicityConfidence,
            'is_saved' => false,
            'scanned_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Scan berhasil',
            'data' => new ScanResultResource($scanResult),
            'model_output' => $prediction,
        ]);
    }

    public function saveScan(Request $request, ScanResult $scanResult): JsonResponse
    {
        // Pastikan milik user yang login
        if ($scanResult->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Setel semua scan lain dari spesies ini menjadi unsaved
        if ($scanResult->butterfly_id) {
            ScanResult::where('user_id', $request->user()->id)
                ->where('butterfly_id', $scanResult->butterfly_id)
                ->where('id', '!=', $scanResult->id)
                ->update(['is_saved' => false]);
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
