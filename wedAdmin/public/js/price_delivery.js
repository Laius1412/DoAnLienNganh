document.addEventListener('DOMContentLoaded', function () {
    let regions = [];
    let priceList = [];
    let editingId = null;
    let selectedIds = new Set();
    let deleteConfirmModal;

    async function loadRegions() {
        const res = await fetch('/delivery/price_delivery/regions');
        regions = await res.json();
        const fromSel = document.getElementById('fromRegion');
        const toSel = document.getElementById('toRegion');
        fromSel.innerHTML = toSel.innerHTML = regions.map(r => `<option value="${r.regionId}">${r.regionName}</option>`).join('');
    }

    async function loadPriceList() {
        const res = await fetch('/delivery/price_delivery/list');
        priceList = await res.json();
        renderPriceList();
    }

    function renderPriceList() {
        const container = document.getElementById('priceDeliveryList');
        if (!priceList.length) {
            container.innerHTML = '<div class="alert alert-info">Chưa có bảng giá nào.</div>';
            return;
        }
        container.innerHTML = priceList.map((item, idx) => {
            const from = regions.find(r => r.regionId === item.fromRegionId)?.regionName || item.fromRegionId;
            const to = regions.find(r => r.regionId === item.toRegionId)?.regionName || item.toRegionId;
            const title = item.fromRegionId === item.toRegionId 
                ? `Bảng giá cước chuyển phát trong khu vực ${from}`
                : `Bảng giá cước chuyển phát ${from} - ${to}`;
            return `
            <div class="card mb-2">
                <div class="card-header d-flex align-items-center">
                    <input type="checkbox" class="form-check-input me-2 price-checkbox" data-id="${item.id}">
                    <button class="btn btn-link flex-grow-1 text-start" type="button" data-bs-toggle="collapse" data-bs-target="#collapse${idx}" aria-expanded="false" aria-controls="collapse${idx}">
                        ${title}
                    </button>
                    <button class="btn btn-warning btn-sm me-2 btn-edit" data-id="${item.id}">Sửa</button>
                </div>
                <div class="collapse" id="collapse${idx}">
                    <div class="card-body">
                        <table class="table table-bordered">
                            <thead>
                                <tr>
                                    <th>Khối lượng tối thiểu (kg)</th>
                                    <th>Khối lượng tối đa (kg)</th>
                                    <th>Giá cước (VND)</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${item.weightRanges.map(r => `
                                    <tr>
                                        <td>${r.min}</td>
                                        <td>${r.max}</td>
                                        <td>${r.price.toLocaleString()}</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>`;
        }).join('');

        document.querySelectorAll('.price-checkbox').forEach(cb => {
            cb.onchange = function () {
                if (this.checked) selectedIds.add(this.dataset.id);
                else selectedIds.delete(this.dataset.id);
                document.getElementById('btnDeleteSelected').disabled = selectedIds.size === 0;
            };
        });

        document.querySelectorAll('.btn-edit').forEach(btn => {
            btn.onclick = function () {
                showEditForm(this.dataset.id);
            };
        });

        document.querySelectorAll('.collapse').forEach(collapseEl => {
            new bootstrap.Collapse(collapseEl, { toggle: false });
        });
    }

    function showForm(editItem = null) {
        editingId = editItem ? editItem.id : null;
        document.getElementById('priceModalTitle').textContent = editingId ? 'Sửa bảng giá' : 'Thêm bảng giá';
        document.getElementById('fromRegion').value = editItem?.fromRegionId || '';
        document.getElementById('toRegion').value = editItem?.toRegionId || '';
        renderWeightRanges(editItem?.weightRanges || []);
        new bootstrap.Modal(document.getElementById('priceModal')).show();
    }

    function showEditForm(id) {
    const item = priceList.find(p => p.id === id); // So sánh chuỗi

    if (!item) {
        alert("Không tìm thấy bảng giá để sửa!");
        return;
    }
    showForm(item);
}

    function renderWeightRanges(ranges) {
        const container = document.getElementById('weightRanges');
        container.innerHTML = '';
        ranges.forEach((r, idx) => addRangeRow(r.min, r.max, r.price, idx));
        if (!ranges.length) addRangeRow();
    }

    function addRangeRow(min = '', max = '', price = '', idx = null) {
        const container = document.getElementById('weightRanges');
        const row = document.createElement('div');
        row.className = 'row g-2 align-items-center mb-2 range-row';
        row.innerHTML = `
            <div class="col"><input type="number" step="0.01" min="0" class="form-control min" placeholder="Min" value="${min}" required></div>
            <div class="col"><input type="number" step="0.01" min="0" class="form-control max" placeholder="Max" value="${max}" required></div>
            <div class="col"><input type="number" step="1000" min="0" class="form-control price" placeholder="Giá" value="${price}" required></div>
            <div class="col-auto"><button type="button" class="btn btn-danger btn-sm btn-remove-range">&times;</button></div>
        `;
        container.appendChild(row);
        row.querySelector('.btn-remove-range').onclick = () => row.remove();
    }

    document.getElementById('btnAddRange').onclick = () => addRangeRow();
    document.getElementById('btnAddPrice').onclick = () => showForm();
    deleteConfirmModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));

    document.getElementById('btnDeleteSelected').onclick = () => {
        if (selectedIds.size === 0) return;
        deleteConfirmModal.show();
    };

    document.getElementById('btnConfirmDelete').onclick = async () => {
        try {
            await fetch('/delivery/price_delivery', {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ids: Array.from(selectedIds) })
            });
            selectedIds.clear();
            deleteConfirmModal.hide();
            window.location.reload();
        } catch (error) {
            window.location.reload();
        }
    };

    document.getElementById('priceForm').onsubmit = async function (e) {
        e.preventDefault();
        const fromRegionId = this.fromRegionId.value;
        const toRegionId = this.toRegionId.value;
        const weightRanges = Array.from(document.querySelectorAll('.range-row')).map(row => ({
            min: parseFloat(row.querySelector('.min').value),
            max: parseFloat(row.querySelector('.max').value),
            price: parseInt(row.querySelector('.price').value)
        }));

        if (!weightRanges.length) {
            window.location.reload();
            return;
        }

        const data = { fromRegionId, toRegionId, weightRanges };

        try {
            let response;
            if (editingId) {
                response = await fetch(`/delivery/price_delivery/${editingId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });
            } else {
                response = await fetch('/delivery/price_delivery', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });
            }

            const result = await response.json();

            if (!response.ok) {
                window.location.reload();
                return;
            }

            window.location.reload();
            
        } catch (error) {
            window.location.reload();
        }
    };

    loadRegions().then(loadPriceList);
});
