class Person {
  final String name;
  final int age;
  final double averageSuccess;

  Person({
    required this.name,
    required this.age,
    required this.averageSuccess,
  });

  // Factory method to create a Person instance from a map (e.g., JSON)
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['Name']?.toString() ?? '',
      age: json['Age'] is int  ? json['Age'] : int.tryParse(json['Age']?.toString() ?? '') ?? 0,
      averageSuccess: json['Average Success'] is double
          ? json['Average Success']
          : double.tryParse(json['Average Success']?.toString() ?? '') ?? 0.0,
    );
  }

  // Method to convert a Person instance to a map (e.g., for JSON)
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Age': age,
      'Average Success': averageSuccess,
    };
  }
}
