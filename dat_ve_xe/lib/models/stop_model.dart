class Stop {
  final String city;
  final List<String> locations;

  Stop({required this.city, required this.locations});

  factory Stop.fromMap(Map<String, dynamic> data) {
    return Stop(
      city: data['city'] ?? '',
      locations: data['locations'] != null
          ? List<String>.from(data['locations'])
          : <String>[],
    );
  }
} 