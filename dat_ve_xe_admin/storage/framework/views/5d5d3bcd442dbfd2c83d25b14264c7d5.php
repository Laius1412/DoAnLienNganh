<!DOCTYPE html>
<html lang="en">
<head>
  <?php echo $__env->make('layout.head', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?>
</head>
<body class="footer-offset has-navbar-vertical-aside navbar-vertical-aside-show-xl">
  <!-- Sidebar trái -->
  <?php echo $__env->make('layout.sidebar', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?>

  <!-- Nội dung chính -->
    <main id="content" role="main" class="main">
    <?php echo $__env->yieldContent('content'); ?>
    </main>

  <?php echo $__env->make('layout.footer', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?>
</body>
</html>
<?php /**PATH E:\GitHub\DoAnLienNganh\dat_ve_xe_admin\resources\views/layout/app.blade.php ENDPATH**/ ?>