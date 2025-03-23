class Laptop {
  final String manufacturer;
  final String screen;
  final double screenSizeCm;
  final double cpuFrequency;
  final double ramGB;
  final double storageGBSSD;
  final double weightKg;

  Laptop({
    required this.manufacturer,
    required this.screen,
    required this.screenSizeCm,
    required this.cpuFrequency,
    required this.ramGB,
    required this.storageGBSSD,
    required this.weightKg,
  });

  Map<String, dynamic> toJson() {
    return {
      'Manufacturer': manufacturer,
      'Screen': screen,
      'Screen_Size_cm': screenSizeCm,
      'CPU_frequency': cpuFrequency,
      'RAM_GB': ramGB,
      'Storage_GB_SSD': storageGBSSD,
      'Weight_kg': weightKg,
    };
  }
}