class Project {
  final String id;
  final String name;
  final String description;

  const Project({required this.id, required this.name, required this.description});

  Project copyWith({String? id, String? name, String? description}) {
    return Project(id: id ?? this.id, name: name ?? this.name, description: description ?? this.description);
  }
}
