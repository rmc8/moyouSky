class AuthorData {
  final String displayName;
  final String handle;
  final String? avatar;
  final String did;

  AuthorData({required this.displayName, required this.handle, required this.avatar, required this.did});

  @override
  String toString() {
    return 'UserProfile(displayName: $displayName, handle: $handle, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthorData &&
        other.displayName == displayName &&
        other.handle == handle &&
        other.avatar == avatar &&
        other.did == did;
  }

  @override
  int get hashCode => displayName.hashCode ^ handle.hashCode ^ avatar.hashCode;
}
