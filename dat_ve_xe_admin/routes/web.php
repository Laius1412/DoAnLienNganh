<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Middleware\CheckAuth;

Route::get('/', function () {
    return redirect('/login');
});

Route::middleware([CheckAuth::class])->group(function () {
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
});

Route::get('/login', [AuthController::class, 'showLogin'])
     ->name('login')
     ->middleware(CheckAuth::class);

Route::post('/login', [AuthController::class, 'login'])
     ->name('login.submit');

Route::get('/logout', [AuthController::class, 'logout'])
     ->name('logout');