/// Android/iOS keep their data in the app sandbox, which the OS does not
/// evict like browser storage, so there is nothing to request there.
Future<void> requestPersistentStorage() async {}
