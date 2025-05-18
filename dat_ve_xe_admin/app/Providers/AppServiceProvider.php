<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth;
use Kreait\Firebase\Database;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Khởi tạo Firebase Factory với service account
        $factory = (new Factory)
            ->withServiceAccount(config('firebase.credentials'));

        // Bind Firebase Auth
        $this->app->singleton(Auth::class, function () use ($factory) {
            return $factory->createAuth();
        });

        // Bind Firebase Realtime Database
        $this->app->singleton(Database::class, function () use ($factory) {
            return $factory->createDatabase();
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
