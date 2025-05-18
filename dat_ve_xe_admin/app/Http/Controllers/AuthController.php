<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Kreait\Firebase\Auth;
use Illuminate\Support\Facades\Session;

class AuthController extends Controller
{
    protected $auth;

    public function __construct(Auth $auth)
    {
        $this->auth = $auth;
    }

    public function showLogin()
    {
        return view('auth.login'); // View login.blade.php
    }

    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        try {
            $signInResult = $this->auth->signInWithEmailAndPassword($request->email, $request->password);
            $firebaseUser = $signInResult->data();

            // Lưu uid vào session
            Session::put('uid', $firebaseUser['localId']);
            return redirect('/admin/dashboard');
        } catch (\Exception $e) {
            return back()->withErrors(['email' => 'Sai email hoặc mật khẩu']);
        }
    }

        public function logout(Request $request)
        {
            // Xóa toàn bộ session + regenerate token
            $request->session()->flush();
            $request->session()->regenerateToken();
            
            return redirect('/login')
                ->header('Cache-Control', 'no-store, no-cache, must-revalidate')
                ->header('Pragma', 'no-cache')
                ->header('Expires', '0');
        }
}
