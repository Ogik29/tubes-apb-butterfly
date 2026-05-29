<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ButterflyController;
use App\Http\Controllers\Api\ScanController;
use App\Http\Controllers\Api\HistoryController;
use App\Http\Controllers\Api\CollectionController;
use App\Http\Controllers\Api\DashboardController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
    });
});

Route::middleware('auth:sanctum')->group(function () {
    
    // User endpoints
    Route::get('/butterflies', [ButterflyController::class, 'index']);
    Route::get('/butterflies/{butterfly}', [ButterflyController::class, 'show']);
    
    Route::post('/scan', [ScanController::class, 'scan']);
    Route::patch('/scan/{scanResult}/save', [ScanController::class, 'saveScan']);
    
    Route::get('/history', [HistoryController::class, 'index']);
    Route::get('/history/{scanResult}', [HistoryController::class, 'show']);
    Route::delete('/history/{scanResult}', [HistoryController::class, 'destroy']);
    
    Route::get('/collection', [CollectionController::class, 'index']);
    
    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);

    // Admin endpoints
    Route::middleware('admin')->group(function () {
        Route::post('/butterflies', [ButterflyController::class, 'store']);
        Route::put('/butterflies/{butterfly}', [ButterflyController::class, 'update']);
        Route::delete('/butterflies/{butterfly}', [ButterflyController::class, 'destroy']);
        
        Route::get('/dashboard/admin-stats', [DashboardController::class, 'adminStats']);
    });
});
