<?php

namespace App\Http\Controllers;

use Google\Cloud\Firestore\FirestoreClient;

class FirestoreController extends Controller
{
    public function readData()
    {
        $firestore = new FirestoreClient([
            'keyFilePath' => storage_path('app/firebase/serviceAccountKey.json'),
            'projectId' => 'flash-b458d',
        ]);

        $collection = $firestore->collection('match_subscriptions');
        $documents = $collection->documents();

        foreach ($documents as $doc) {
            if ($doc->exists()) {
                echo '<pre>';
                print_r($doc->data());
                echo '</pre>';
            }
        }
    }
}
