enum SyncStatus {
  pending,
  synced,
  failed;

  String get storageKey => name;

  static SyncStatus fromStorageKey(String? value) {
    return SyncStatus.values.firstWhere(
      (status) => status.storageKey == value,
      orElse: () => SyncStatus.pending,
    );
  }
}
