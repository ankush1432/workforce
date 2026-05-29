enum FaceRegistrationStatus {
  registered,
  notRegistered,
  pendingSync;

  static FaceRegistrationStatus fromApi(String? value) {
    switch (value) {
      case 'registered':
        return FaceRegistrationStatus.registered;
      case 'pending_sync':
        return FaceRegistrationStatus.pendingSync;
      default:
        return FaceRegistrationStatus.notRegistered;
    }
  }

  String get apiValue => switch (this) {
        FaceRegistrationStatus.registered => 'registered',
        FaceRegistrationStatus.pendingSync => 'pending_sync',
        FaceRegistrationStatus.notRegistered => 'not_registered',
      };

  String get label => switch (this) {
        FaceRegistrationStatus.registered => 'Face Registered',
        FaceRegistrationStatus.pendingSync => 'Pending Sync',
        FaceRegistrationStatus.notRegistered => 'Face Not Registered',
      };

  bool get needsRegistration =>
      this == FaceRegistrationStatus.notRegistered ||
      this == FaceRegistrationStatus.pendingSync;
}
