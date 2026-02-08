class ButtonConfig {
  final int id;
  final String name;
  final String key;
  final String sound;
  String icon;

  ButtonConfig({
    required this.id,
    required this.name,
    required this.key,
    required this.sound,
    this.icon = '',
  });

  factory ButtonConfig.fromJson(Map<String, dynamic> json) {
    return ButtonConfig(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      key: json['key'] ?? '',
      sound: json['sound'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key': key,
      'sound': sound,
      'icon': icon,
    };
  }
}
