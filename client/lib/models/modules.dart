// models/module_model.dart
class ModuleModel {
  final String id;
  final String name;
  final String? description;
  final String orgId;

  ModuleModel({
    required this.id,
    required this.name,
    this.description,
    required this.orgId,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      orgId: json['orgId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'orgId': orgId,
    };
  }
}
