class AppUser {
  final String id; // e.g. phone number in E.164 or generated id
  final String name;
  final String? phone;

  AppUser({required this.id, required this.name, this.phone});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        phone: m['phone'] as String?,
      );
}
