import '../services/cycle_service.dart';

class PackageGroup {
  const PackageGroup({
    required this.id,
    required this.name,
    required this.renewalDay,
    required this.currentCompanyCost,
    required this.currentCycleStartDate,
    required this.lastResetCycleStartDate,
  });

  final String id;
  final String name;
  final int renewalDay;
  final double currentCompanyCost;
  final DateTime currentCycleStartDate;
  final DateTime lastResetCycleStartDate;

  PackageGroup copyWith({
    String? id,
    String? name,
    int? renewalDay,
    double? currentCompanyCost,
    DateTime? currentCycleStartDate,
    DateTime? lastResetCycleStartDate,
  }) {
    return PackageGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      renewalDay: renewalDay ?? this.renewalDay,
      currentCompanyCost: currentCompanyCost ?? this.currentCompanyCost,
      currentCycleStartDate:
          currentCycleStartDate ?? this.currentCycleStartDate,
      lastResetCycleStartDate:
          lastResetCycleStartDate ?? this.lastResetCycleStartDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'renewalDay': renewalDay,
      'currentCompanyCost': currentCompanyCost,
      'currentCycleStartDate': currentCycleStartDate.toIso8601String(),
      'lastResetCycleStartDate': lastResetCycleStartDate.toIso8601String(),
    };
  }

  factory PackageGroup.fromMap(Map<String, dynamic> map) {
    return PackageGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      renewalDay: map['renewalDay'] as int,
      currentCompanyCost: (map['currentCompanyCost'] as num).toDouble(),
      currentCycleStartDate:
          DateTime.parse(map['currentCycleStartDate'] as String),
      lastResetCycleStartDate:
          DateTime.parse(map['lastResetCycleStartDate'] as String),
    );
  }

  factory PackageGroup.defaultGroup({
    required int index,
    required DateTime today,
    double companyCost = 0,
    int? renewalDay,
  }) {
    final resolvedRenewalDay = renewalDay ?? (index == 2 ? 16 : 1);
    final cycleStart = CycleService.getCurrentCycleStartDate(
      resolvedRenewalDay,
      today,
    );

    return PackageGroup(
      id: 'group_$index',
      name: 'Group $index',
      renewalDay: resolvedRenewalDay,
      currentCompanyCost: companyCost,
      currentCycleStartDate: cycleStart,
      lastResetCycleStartDate: cycleStart,
    );
  }
}
