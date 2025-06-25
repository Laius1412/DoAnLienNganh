class Trip {
  final String id;
  final String destination;
  final String nameTrip;
  final String startLocation;
  final String tripCode;
  final String vRouter;
  final List<String> intermediateStops;

  Trip({
    required this.id,
    required this.destination,
    required this.nameTrip,
    required this.startLocation,
    required this.tripCode,
    required this.vRouter,
    required this.intermediateStops,
  });

  factory Trip.fromMap(String id, Map<String, dynamic> data) {
    return Trip(
      id: id,
      destination: data['destination'],
      nameTrip: data['nameTrip'],
      startLocation: data['startLocation'],
      tripCode: data['tripCode'],
      vRouter: data['vRouter'],
      intermediateStops: data['intermediateStops'] != null
        ? List<String>.from(data['intermediateStops'])
        : <String>[],
    );
  }
}
