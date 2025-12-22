class BlockModel {
  final String id;
  final DateTime createdAt;
  final BlockUser blocker;
  final BlockUser blocked;

  BlockModel({
    required this.id,
    required this.createdAt,
    required this.blocker,
    required this.blocked,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      id: json['id'] ?? '',
      // Supabase returns ISO string for timestamptz
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      blocker: BlockUser.fromJson(json['blocker'] ?? {}),
      blocked: BlockUser.fromJson(json['blocked'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'blocker_id': blocker.id,
      'blocked_id': blocked.id,
    };
  }
}

class BlockUser {
  final String id;
  final String name;
  final String userName;
  final String image;

  BlockUser({
    required this.id,
    required this.name,
    required this.userName,
    required this.image,
  });

  factory BlockUser.fromJson(Map<String, dynamic> json) {
    return BlockUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userName: json['userName'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'userName': userName, 'image': image};
  }
}
