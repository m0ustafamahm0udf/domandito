class VersionModel {
  final String version;
  final bool isForce;
  final String iosLink;
  final String androidLink;
  final String description;

  VersionModel(
      {required this.version,
      required this.isForce,
      required this.iosLink,
      required this.androidLink,
      required this.description});

  // Factory constructor to create an instance from JSON
  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      version: json['Version'] ?? "",
      isForce: json['IsForce'] ?? false,
      iosLink: json['IosLink'] ?? "",
      androidLink: json['AndroidLink'] ?? "",
      description: json['Description'] ?? "",
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'IsForce': isForce,
      'IosLink': iosLink,
      'AndroidLink': androidLink,
      'Description': description,
    };
  }
}
