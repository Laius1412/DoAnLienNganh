<!DOCTYPE html>
<html lang="en">
<head>
  @include('layout.head')
</head>
<body class="footer-offset has-navbar-vertical-aside navbar-vertical-aside-show-xl">
  <!-- Sidebar trái -->
  @include('layout.sidebar')

  <!-- Nội dung chính -->
    <main id="content" role="main" class="main">
    @yield('content')
    </main>

  @include('layout.footer')
</body>
</html>
