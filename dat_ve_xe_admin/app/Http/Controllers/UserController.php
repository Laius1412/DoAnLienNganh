<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Google\Cloud\Firestore\FirestoreClient;

class UserController extends Controller
{
    public function index()
    {
        // Kết nối Firestore
        $firestore = new FirestoreClient([
            'keyFilePath' => storage_path('app/firebase/firebase_credentials.json'),
            'projectId' => 'flash-travel', // Project ID của bạn
        ]);

        // Lấy collection 'users'
        $usersRef = $firestore->collection('users');
        $documents = $usersRef->documents();

        $users = [];
        foreach ($documents as $doc) {
            if ($doc->exists()) {
                $data = $doc->data();
                $data['id'] = $doc->id(); // thêm id nếu cần
                $users[] = $data;
            }
        }

        // Trả dữ liệu ra view
        return view('admin.user.index', compact('users'));
    }
}
