class ResidentAllergy {
  final int id;
  final String allergenName;
  final String reaction;
  final String severityLevel;
  final String typeOfAllergy;

  const ResidentAllergy({
    required this.id,
    required this.allergenName,
    required this.reaction,
    required this.severityLevel,
    required this.typeOfAllergy,
  });
}

class ResidentVitalSign {
  final int id;
  final String measurementId;
  final String severityLevel;

  const ResidentVitalSign({
    required this.id,
    required this.measurementId,
    required this.severityLevel,
  });
}
