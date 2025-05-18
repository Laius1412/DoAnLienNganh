<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Session; // Thêm dòng này

class CheckAuth
{
public function handle($request, Closure $next)
{
    if ($request->is('login') || $request->is('logout')) {
        return $next($request);
    }

    // Nếu đã đăng nhập
    if (Session::has('uid')) {
        // Chặn truy cập trang login (redirect đến dashboard)
        if ($request->is('login')) {
            return redirect('/admin/dashboard');
        }
        return $next($request);
    }

    // Nếu chưa đăng nhập và cố truy cập trang admin
    if ($request->is('admin/*') || $request->is('/')) {
        return redirect('/login')->with('error', 'Vui lòng đăng nhập');
    }

    return $next($request);
}
}