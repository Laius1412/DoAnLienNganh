document.addEventListener('DOMContentLoaded', function() {
    let deleteInfo = { type: null, id: null };

    // Hàm hiển thị thông báo
    function showAlert(message, type = 'success') {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed top-0 end-0 m-3`;
        alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        document.body.appendChild(alertDiv);
        setTimeout(() => alertDiv.remove(), 3000);
    }

    // Xử lý nút xác nhận xóa
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
    if (confirmDeleteBtn) {
        confirmDeleteBtn.addEventListener('click', async function () {
            try {
                if (deleteInfo.type === 'region') {
                    await deleteRegion(deleteInfo.id);
                    showAlert('Xóa khu vực thành công');
                } else if (deleteInfo.type === 'office') {
                    await deleteOffice(deleteInfo.id);
                    showAlert('Xóa văn phòng thành công');
                }
            } catch (error) {
                showAlert('Có lỗi xảy ra khi xóa', 'danger');
            }
        });
    }

    // Xử lý nút Hủy - reset form và đóng modal
    document.querySelectorAll('.modal-footer .btn-secondary').forEach(button => {
        button.addEventListener('click', function() {
            const modal = this.closest('.modal');
            const form = modal.querySelector('form');
            if (form) {
                form.reset();
            }
            const modalInstance = bootstrap.Modal.getInstance(modal);
            if (modalInstance) {
                modalInstance.hide();
            }
        });
    });

    // Xử lý nút X - chỉ đóng modal
    document.querySelectorAll('.modal-header .btn-close').forEach(button => {
        button.addEventListener('click', function() {
            const modal = this.closest('.modal');
            const modalInstance = bootstrap.Modal.getInstance(modal);
            if (modalInstance) {
                modalInstance.hide();
            }
        });
    });

    // Xử lý form thêm khu vực
    const addRegionForm = document.getElementById('addRegionForm');
    if (addRegionForm) {
        addRegionForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            try {
                const formData = new FormData(this);
                const data = {
                    regionId: formData.get('regionId'),
                    regionName: formData.get('regionName')
                };

                const response = await fetch('/delivery/regions', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });

                if (!response.ok) throw new Error('Lỗi khi thêm khu vực');
                
                showAlert('Thêm khu vực thành công');
                window.location.reload();
            } catch (error) {
                console.error('Error:', error);
                showAlert('Có lỗi xảy ra khi thêm khu vực', 'danger');
            }
        });
    }

    // Xử lý form thêm văn phòng
    const addOfficeForm = document.getElementById('addOfficeForm');
    if (addOfficeForm) {
        addOfficeForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            try {
                const formData = new FormData(this);
                const data = {
                    officeId: formData.get('officeId'),
                    officeName: formData.get('officeName'),
                    regionId: formData.get('regionId'),
                    address: formData.get('address'),
                    hotline: formData.get('hotline')
                };

                const response = await fetch('/delivery/office', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });

                if (!response.ok) throw new Error('Lỗi khi thêm văn phòng');
                
                showAlert('Thêm văn phòng thành công');
                window.location.reload();
            } catch (error) {
                console.error('Error:', error);
                showAlert('Có lỗi xảy ra khi thêm văn phòng', 'danger');
            }
        });
    }

    // Xử lý form sửa khu vực
    const editRegionForm = document.getElementById('editRegionForm');
    if (editRegionForm) {
        editRegionForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            try {
                const formData = new FormData(this);
                const oldRegionId = formData.get('oldRegionId');
                const data = {
                    regionId: formData.get('regionId'),
                    regionName: formData.get('regionName')
                };

                const response = await fetch(`/delivery/regions/${oldRegionId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });

                if (!response.ok) throw new Error('Lỗi khi cập nhật khu vực');
                
                showAlert('Cập nhật khu vực thành công');
                window.location.reload();
            } catch (error) {
                console.error('Error:', error);
                showAlert('Có lỗi xảy ra khi cập nhật khu vực', 'danger');
            }
        });
    }

    // Xử lý form sửa văn phòng
    const editOfficeForm = document.getElementById('editOfficeForm');
    if (editOfficeForm) {
        editOfficeForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            try {
                const formData = new FormData(this);
                const officeId = formData.get('officeId');
                const data = {
                    officeName: formData.get('officeName'),
                    address: formData.get('address'),
                    hotline: formData.get('hotline')
                };

                const response = await fetch(`/delivery/office/${officeId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });

                if (!response.ok) throw new Error('Lỗi khi cập nhật văn phòng');
                
                showAlert('Cập nhật văn phòng thành công');
                window.location.reload();
            } catch (error) {
                console.error('Error:', error);
                showAlert('Có lỗi xảy ra khi cập nhật văn phòng', 'danger');
            }
        });
    }

    // Hàm load danh sách khu vực
    async function loadRegions() {
        try {
            const response = await fetch('/delivery/regions');
            if (!response.ok) throw new Error('Lỗi khi tải danh sách khu vực');
            
            const regions = await response.json();
            const regionList = document.getElementById('regionList');
            regionList.innerHTML = regions.map(region => createRegionItem(region)).join('');
        } catch (error) {
            console.error('Error loading regions:', error);
            showAlert('Có lỗi xảy ra khi tải danh sách khu vực', 'danger');
        }
    }

    function createRegionItem(region) {
        return `
            <div class="list-group-item d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center flex-grow-1">
                    <span class="region-name me-2 text-primary" style="cursor:pointer" onclick="loadOffices('${region.regionId}')">
                        ${region.regionName}
                    </span>
                    <small class="text-muted">(${region.regionId})</small>
                </div>
                <div class="btn-group">
                    <button class="btn btn-sm btn-outline-warning" onclick="editRegion('${region.regionId}', '${region.regionName}')" title="Sửa khu vực">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="showDeleteConfirm('region', '${region.regionId}', '${region.regionName}')" title="Xóa khu vực">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        `;
    }

    window.loadOffices = async function(regionId) {
        try {
            const response = await fetch(`/delivery/offices/${regionId}`);
            if (!response.ok) throw new Error('Lỗi khi tải danh sách văn phòng');
            
            const offices = await response.json();
            const officeList = document.getElementById('officeList');
            officeList.innerHTML = offices.length
                ? offices.map(createOfficeItem).join('')
                : '<div class="list-group-item text-center text-muted">Không có văn phòng nào</div>';

            document.getElementById('addOfficeBtn').disabled = false;
            document.getElementById('officeRegionId').value = regionId;
        } catch (error) {
            console.error('Error loading offices:', error);
            showAlert('Có lỗi xảy ra khi tải danh sách văn phòng', 'danger');
        }
    };

    function createOfficeItem(office) {
        return `
            <div class="list-group-item d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center flex-grow-1">
                    <span class="office-name me-2 text-primary" style="cursor:pointer" onclick="showOfficeDetails('${office.officeId}')">
                        ${office.officeName}
                    </span>
                    <small class="text-muted">(${office.officeId})</small>
                </div>
                <div class="btn-group">
                    <button class="btn btn-sm btn-outline-warning" onclick="editOffice('${office.officeId}')" title="Sửa văn phòng">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="showDeleteConfirm('office', '${office.officeId}', '${office.officeName}')" title="Xóa văn phòng">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        `;
    }

    window.showOfficeDetails = async function(officeId) {
        try {
            const response = await fetch(`/delivery/office/${officeId}`);
            if (!response.ok) throw new Error('Lỗi khi tải thông tin văn phòng');
            
            const office = await response.json();
            const officeDetails = document.getElementById('officeDetails');
            officeDetails.innerHTML = `
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">${office.officeName}</h5>
                        <p class="card-text"><strong>ID:</strong> ${office.officeId}</p>
                        <p class="card-text"><strong>Địa chỉ:</strong> ${office.address}</p>
                        <p class="card-text"><strong>Hotline:</strong> ${office.hotline}</p>
                    </div>
                </div>
            `;
        } catch (error) {
            console.error('Error loading office details:', error);
            showAlert('Có lỗi xảy ra khi tải thông tin văn phòng', 'danger');
        }
    };

    window.editRegion = function(regionId, regionName) {
        const editRegionForm = document.getElementById('editRegionForm');
        const oldInput = editRegionForm.querySelector('input[name="oldRegionId"]');
        if (oldInput) oldInput.remove();

        document.getElementById('editRegionId').value = regionId;
        document.getElementById('editRegionName').value = regionName;

        const hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = 'oldRegionId';
        hiddenInput.value = regionId;
        editRegionForm.appendChild(hiddenInput);

        const modal = new bootstrap.Modal(document.getElementById('editRegionModal'));
        modal.show();
    };

    window.editOffice = async function(officeId) {
        try {
            const response = await fetch(`/delivery/office/${officeId}`);
            if (!response.ok) throw new Error('Lỗi khi tải thông tin văn phòng');
            
            const office = await response.json();
            document.getElementById('editOfficeId').value = office.officeId;
            document.getElementById('editOfficeName').value = office.officeName;
            document.getElementById('editAddress').value = office.address;
            document.getElementById('editHotline').value = office.hotline;
            
            const modal = new bootstrap.Modal(document.getElementById('editOfficeModal'));
            modal.show();
        } catch (error) {
            console.error('Error loading office details:', error);
            showAlert('Có lỗi xảy ra khi tải thông tin văn phòng', 'danger');
        }
    };

    window.showDeleteConfirm = function(type, id, name) {
        deleteInfo = { type, id };
        const message = type === 'region'
            ? `Bạn có chắc chắn muốn xóa khu vực "${name}"?`
            : `Bạn có chắc chắn muốn xóa văn phòng "${name}"?`;
        document.getElementById('deleteConfirmMessage').textContent = message;
        new bootstrap.Modal(document.getElementById('deleteConfirmModal')).show();
    };

    window.deleteRegion = async function(regionId) {
        try {
            const response = await fetch(`/delivery/regions/${regionId}`, { method: 'DELETE' });
            if (!response.ok) throw new Error('Lỗi khi xóa khu vực');
            window.location.reload();
        } catch (error) {
            console.error('Error:', error);
            showAlert('Có lỗi xảy ra khi xóa khu vực', 'danger');
        }
    };

    window.deleteOffice = async function(officeId) {
        try {
            const response = await fetch(`/delivery/office/${officeId}`, { method: 'DELETE' });
            if (!response.ok) throw new Error('Lỗi khi xóa văn phòng');
            window.location.reload();
        } catch (error) {
            console.error('Error:', error);
            showAlert('Có lỗi xảy ra khi xóa văn phòng', 'danger');
        }
    };

    // Load danh sách khu vực khi trang được tải
    loadRegions();
});
