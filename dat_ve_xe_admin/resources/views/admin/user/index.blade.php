@extends('layout.app')


@section('content')
<div class="container mt-4">
    <h2>Danh sách người dùng</h2>
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>Họ tên</th>
                <th>Email</th>
                <th>Giới tính</th>
                <th>Ngày sinh</th>
                <th>SĐT</th>
                <th>Vai trò</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($users as $user)
            <tr>
                <td>{{ $user['name'] ?? '' }}</td>
                <td>{{ $user['email'] ?? '' }}</td>
                <td>{{ $user['gender'] ?? '' }}</td>
                <td>{{ isset($user['birth']) ? \Carbon\Carbon::parse($user['birth'])->format('d/m/Y') : '' }}</td>
                <td>{{ $user['phone'] ?? '' }}</td>
                <td>{{ $user['role'] ?? '' }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
