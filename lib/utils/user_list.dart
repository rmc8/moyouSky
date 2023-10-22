class Actor {
  final String avatarUrl;
  final String displayName;
  final String handle;

  Actor({required this.avatarUrl, required this.displayName, required this.handle});

  factory Actor.fromMap(Map<String, dynamic> map) {
    return Actor(
      avatarUrl: map['avatar'] ?? '',
      handle: map['handle'],
      displayName: map['displayName'] ?? map['handle'] ?? '{Null}',
    );
  }
}
