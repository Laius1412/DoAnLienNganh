

<?php $__env->startSection('title', 'Dashboard'); ?>
<?php $__env->startSection('content'); ?>
    <!-- Content -->
    <div class="bg-dark">
      <div class="content container-fluid" style="height: 25rem;">
        <!-- Page Header -->
        <div class="page-header page-header-light">
          <div class="row align-items-center">
            <div class="col">
              <h1 class="page-header-title">Dashboard</h1>
            </div>

            <div class="col-auto">
              <a class="btn btn-primary" href="#">My dashboard</a>
            </div>
          </div>
          <!-- End Row -->
        </div>
        <!-- End Page Header -->
      </div>
    </div>
    <!-- End Content -->

    <!-- Content -->
    <div class="content container-fluid" style="margin-top: -18rem;">
      <!-- Card -->
      <div class="card mb-3 mb-lg-5">
        <div class="card-body card-body-centered py-10 my-lg-10">
          <!-- Title -->
          <div class="text-center">
            <img class="img-fluid shadow-soft mb-5" src="..\assets\svg\layouts\content-combinations-overlay.svg" alt="Image Description" style="max-width: 15rem;">

            <h1>Overlay - Content Combinations</h1>
            <p>Customize your overview page layout. Choose the one that best fits your needs.</p>
            <a class="btn btn-primary" href="layouts.html">Go back to Layouts</a>
          </div>
          <!-- End Title -->
        </div>
      </div>
      <!-- End Card -->

      <!-- Card -->
      <div class="card">
        <div class="card-body card-body-centered py-10">
          <img class="avatar avatar-xl mb-3" src="..\assets\svg\illustrations\yelling.svg" alt="Image Description">
          <p class="card-text">No data to show</p>
          <a class="btn btn-sm btn-white" href="..\index.html">Get Started</a>
        </div>
      </div>
      <!-- End Card -->
    </div>
    <!-- End Content -->
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layout.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH E:\GitHub\DoAnLienNganh\dat_ve_xe_admin\resources\views/admin/dashboard.blade.php ENDPATH**/ ?>