/// Cloud-save abstraction. The app ships with a [NoOpCloudSaveService] so it is
/// fully offline by default; a Firebase-backed implementation can be dropped in
/// later without touching the rest of the app (the interface is stable).
library;

import 'models.dart';

abstract class CloudSaveService {
  const CloudSaveService();

  /// Fetches the latest cloud snapshot, or null if none / disabled.
  Future<PlayerData?> fetch();

  /// Pushes the latest local data to the cloud.
  Future<void> push(PlayerData data);
}

/// The default: does nothing, keeping the game 100% local & private.
class NoOpCloudSaveService extends CloudSaveService {
  const NoOpCloudSaveService();

  @override
  Future<PlayerData?> fetch() async => null;

  @override
  Future<void> push(PlayerData data) async {}
}

// --- Firebase drop-in (prepared, commented) --------------------------------
// To enable cloud sync later:
//  1. Uncomment the firebase deps in pubspec.yaml.
//  2. Add google-services.json / GoogleService-Info.plist.
//  3. Provide FirebaseCloudSaveService below and pass it to SaveRepository.
//
// class FirebaseCloudSaveService extends CloudSaveService {
//   FirebaseCloudSaveService(this._userId);
//   final String _userId;
//   @override
//   Future<PlayerData?> fetch() async { /* read Firestore doc -> PlayerData */ }
//   @override
//   Future<void> push(PlayerData data) async { /* write PlayerData -> Firestore */ }
// }
