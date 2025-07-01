// Xử lý giao diện quản lý đơn hàng giao hàng
// Sử dụng fetch để lấy dữ liệu từ các API backend

let orders = [];
let offices = [];
let regions = [];
let users = [];

// Lấy danh sách đơn hàng, offices, regions, users khi load trang
async function fetchInitialData() {
  const [ordersRes, officesRes, regionsRes, usersRes] = await Promise.all([
    fetch('/delivery/api/delivery-orders').then(r => r.json()),
    fetch('/delivery/api/offices').then(r => r.json()),
    fetch('/delivery/api/regions').then(r => r.json()),
    fetch('/delivery/api/users').then(r => r.json()),
  ]);
  offices = officesRes?.data || [];
  regions = regionsRes?.data || [];
  users = usersRes?.data || [];
  orders = ordersRes?.data || [];
  renderOrdersTable(orders);
}

function renderOrdersTable(data) {
  const tbody = document.querySelector('#orders-table tbody');
  tbody.innerHTML = '';
  data.forEach(order => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${order.id}</td>
      <td>${order.phoneFrom}</td>
      <td>${formatDate(order.createdAt)}</td>
      <td>${getStatusText(order.status)}</td>
      <td>
        <button class="btn btn-info btn-sm me-1" onclick="showOrderDetail('${order.id}', false)">Xem chi tiết</button>
        <button class="btn btn-warning btn-sm" onclick="showOrderDetail('${order.id}', true)">Chỉnh sửa</button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function formatDate(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return d.toLocaleString('vi-VN');
}

function getStatusText(status) {
  const map = {
    pending: 'Chờ xác nhận',
    confirmed: 'Đã xác nhận',
    accepted: 'Đã tiếp nhận',
    delivering: 'Đang vận chuyển',
    delivered: 'Đã tới nơi',
    returning: 'Đang hoàn trả',
    returned: 'Đã hoàn trả',
    received: 'Người nhận đã nhận hàng',
    refused: 'Từ chối nhận hàng',
  };
  return map[status] || status;
}

// Tìm kiếm theo ngày
const btnFilter = document.getElementById('btn-filter-date');
btnFilter.addEventListener('click', () => {
  const dateVal = document.getElementById('filter-date').value;
  if (!dateVal) {
    renderOrdersTable(orders);
    return;
  }
  const filtered = orders.filter(o => {
    const d = new Date(o.createdAt);
    const dStr = d.toISOString().slice(0, 10);
    return dStr === dateVal;
  });
  renderOrdersTable(filtered);
});

// Xem chi tiết hoặc chỉnh sửa đơn hàng
window.showOrderDetail = function(orderId, isEdit) {
  const order = orders.find(o => o.id === orderId);
  if (!order) return;
  // Lấy nơi gửi
  const fromOffice = offices.find(of => of.officeId === order.fromOfficeId);
  const fromRegion = regions.find(rg => rg.regionId === order.fromRegionId);
  const fromStr = `${fromOffice ? fromOffice.officeName : order.fromOfficeId}, ${fromRegion ? fromRegion.regionName : order.fromRegionId}`;
  // Lấy nơi nhận
  const toOffice = offices.find(of => of.officeId === order.toOfficeId);
  const toRegion = regions.find(rg => rg.regionId === order.toRegionId);
  const toStr = `${toOffice ? toOffice.officeName : order.toOfficeId}, ${toRegion ? toRegion.regionName : order.toRegionId}`;

  // Hiển thị thông tin
  document.getElementById('order-id').value = order.id;
  document.getElementById('order-createdAt').value = formatDate(order.createdAt);
  document.getElementById('order-nameFrom').value = order.nameFrom;
  document.getElementById('order-phoneFrom').value = order.phoneFrom;
  document.getElementById('order-from').value = fromStr;
  document.getElementById('order-nameTo').value = order.nameTo;
  document.getElementById('order-phoneTo').value = order.phoneTo;
  document.getElementById('order-to').value = toStr;
  document.getElementById('order-details').value = order.details;
  document.getElementById('order-mass').value = order.mass;
  document.getElementById('order-type').value = order.type === 'highvalue' ? 'Hàng giá trị cao' : 'Hàng thường';
  document.getElementById('order-cccd').value = order.cccd || '';
  document.getElementById('order-ordervalue').value = order.ordervalue || '';
  document.getElementById('order-paymentType').value = order.paymentType === 'postPayment' ? 'Người gửi trả tiền' : 'Người nhận trả tiền';
  document.getElementById('order-cod').value = order.cod || '';
  document.getElementById('order-price').value = order.price || '';
  document.getElementById('order-status').value = getStatusText(order.status);

  // Hiện/ẩn các trường highvalue
  document.getElementById('cccd-group').classList.toggle('d-none', order.type !== 'highvalue');
  document.getElementById('ordervalue-group').classList.toggle('d-none', order.type !== 'highvalue');

  // Nếu là chỉnh sửa
  if (isEdit) {
    document.getElementById('edit-fields').classList.remove('d-none');
    document.getElementById('btn-save-edit').classList.remove('d-none');
    document.getElementById('edit-mass').value = order.mass;
    document.getElementById('edit-status').value = order.status;
    // Enable input
    document.getElementById('edit-mass').disabled = false;
    document.getElementById('edit-status').disabled = false;
    // Ẩn các input readonly
    document.getElementById('order-mass').parentElement.classList.add('d-none');
    document.getElementById('order-status').parentElement.classList.add('d-none');
  } else {
    document.getElementById('edit-fields').classList.add('d-none');
    document.getElementById('btn-save-edit').classList.add('d-none');
    // Show readonly
    document.getElementById('order-mass').parentElement.classList.remove('d-none');
    document.getElementById('order-status').parentElement.classList.remove('d-none');
  }

  // Lưu id đơn hàng đang xem/sửa
  document.getElementById('orderModal').setAttribute('data-order-id', order.id);

  // Hiện modal
  const modal = new bootstrap.Modal(document.getElementById('orderModal'));
  modal.show();
};

// Lưu chỉnh sửa
const btnSaveEdit = document.getElementById('btn-save-edit');
btnSaveEdit.addEventListener('click', async () => {
  const orderId = document.getElementById('orderModal').getAttribute('data-order-id');
  const newMass = document.getElementById('edit-mass').value;
  const newStatus = document.getElementById('edit-status').value;
  const res = await fetch(`/delivery/api/delivery-orders/${orderId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ mass: newMass, status: newStatus })
  });
  if (res.ok) {
    // Cập nhật lại dữ liệu
    // await fetchInitialData();
    // Đóng modal
    // bootstrap.Modal.getInstance(document.getElementById('orderModal')).hide();
    alert('Cập nhật thành công!');
    window.location.reload(); // Reload lại trang
  } else {
    alert('Cập nhật thất bại!');
  }
});

// Khởi động
window.addEventListener('DOMContentLoaded', fetchInitialData); 