import 'package:uuid/uuid.dart';

import '../models/customer_model.dart';
import '../models/customer_snapshot_model.dart';
import '../models/group_model.dart';
import '../models/monthly_history_model.dart';
import 'cycle_service.dart';

class HistoryService {
  HistoryService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  MonthlyHistory createMonthlyHistory({
    required PackageGroup group,
    required List<Customer> activeCustomers,
    DateTime? cycleStartDate,
    DateTime? cycleEndDate,
  }) {
    final collected = activeCustomers
        .where((customer) => customer.isPaid)
        .fold<double>(0, (sum, customer) => sum + customer.price);
    final pending = activeCustomers
        .where((customer) => !customer.isPaid)
        .fold<double>(0, (sum, customer) => sum + customer.price);
    final expected = collected + pending;
    final startDate = cycleStartDate ?? group.currentCycleStartDate;
    final endDate = cycleEndDate ??
        CycleService.getCycleEndDate(startDate, group.renewalDay);

    return MonthlyHistory(
      id: _uuid.v4(),
      groupId: group.id,
      groupName: group.name,
      cycleStartDate: startDate,
      cycleEndDate: endDate,
      companyCost: group.currentCompanyCost,
      totalCollected: collected,
      totalPending: pending,
      totalExpectedSales: expected,
      netProfit: collected - group.currentCompanyCost,
      customersSnapshot:
          activeCustomers.map(CustomerSnapshot.fromCustomer).toList(),
    );
  }
}
