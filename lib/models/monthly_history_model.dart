import 'customer_snapshot_model.dart';

class MonthlyHistory {
  const MonthlyHistory({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.cycleStartDate,
    required this.cycleEndDate,
    required this.companyCost,
    required this.totalCollected,
    required this.totalPending,
    required this.totalExpectedSales,
    required this.netProfit,
    required this.customersSnapshot,
  });

  final String id;
  final String groupId;
  final String groupName;
  final DateTime cycleStartDate;
  final DateTime cycleEndDate;
  final double companyCost;
  final double totalCollected;
  final double totalPending;
  final double totalExpectedSales;
  final double netProfit;
  final List<CustomerSnapshot> customersSnapshot;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'cycleStartDate': cycleStartDate.toIso8601String(),
      'cycleEndDate': cycleEndDate.toIso8601String(),
      'companyCost': companyCost,
      'totalCollected': totalCollected,
      'totalPending': totalPending,
      'totalExpectedSales': totalExpectedSales,
      'netProfit': netProfit,
      'customersSnapshot': customersSnapshot.map((item) => item.toMap()).toList(),
    };
  }

  factory MonthlyHistory.fromMap(Map<String, dynamic> map) {
    final rawCustomers = (map['customersSnapshot'] as List?) ?? <dynamic>[];
    return MonthlyHistory(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      cycleStartDate: DateTime.parse(map['cycleStartDate'] as String),
      cycleEndDate: DateTime.parse(map['cycleEndDate'] as String),
      companyCost: (map['companyCost'] as num).toDouble(),
      totalCollected: (map['totalCollected'] as num).toDouble(),
      totalPending: (map['totalPending'] as num).toDouble(),
      totalExpectedSales: (map['totalExpectedSales'] as num).toDouble(),
      netProfit: (map['netProfit'] as num).toDouble(),
      customersSnapshot: rawCustomers
          .map((item) => CustomerSnapshot.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}
