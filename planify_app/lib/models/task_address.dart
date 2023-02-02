class TaskAddress {
  final double? latitude;
  final double? longitude;
  final String? address;

  const TaskAddress({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}
