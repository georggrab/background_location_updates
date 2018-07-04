/// Represents the PermissionState of Background Location on iOS,
/// and ACCESS_COARSE_LOCATION or ACCESS_FINE_LOCATION on Android.
enum PermissionState {
  /// Indicates that the Permission was Granted.
  GRANTED,

  /// Only on iOS: Indicates that the Permission was granted, but only
  /// while the Application is running, not while in the Background.
  PARTIAL,

  /// Indicates that the Permission has been denied.
  DENIED
}

/// Maps the Native Channel Code to a [PermissionState] enum.
///
/// Throws if [nativeCode] is a value that is not defined.
PermissionState toPermissionState(int nativeCode) {
  switch (nativeCode) {
    case 1:
      return PermissionState.GRANTED;
    case 2:
      return PermissionState.PARTIAL;
    case 3:
      return PermissionState.DENIED;
    default:
      throw 'Constructed invalid permissionState from native code: $nativeCode';
  }
}
