class TaskAdress {
  final double? latitude;
  final double? longitude;
  final String? address;

  const TaskAdress({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}
