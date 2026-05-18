import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/customer_model.dart';
import '../models/group_model.dart';
import '../models/monthly_history_model.dart';
import '../services/cycle_service.dart';
import '../services/history_service.dart';
import '../services/local_database_service.dart';
import '../services/settings_service.dart';
import '../utils/date_utils.dart';

class GroupFinancialSummary {
  const GroupFinancialSummary({
    required this.totalCollected,
    required this.totalPending,
    required this.totalExpectedSales,
    required this.companyCost,
    required this.netProfit,
    required this.paidCount,
    required this.unpaidCount,
    required this.customerCount,
  });

  final double totalCollected;
  final double totalPending;
  final double totalExpectedSales;
  final double companyCost;
  final double netProfit;
  final int paidCount;
  final int unpaidCount;
  final int customerCount;

  bool get hasPendingCustomers => unpaidCount > 0;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalCollected,
    required this.totalPending,
    required this.totalExpectedSales,
    required this.companyCosts,
    required this.netProfit,
    required this.paidCustomersCount,
    required this.unpaidCustomersCount,
  });

  final double totalCollected;
  final double totalPending;
  final double totalExpectedSales;
  final double companyCosts;
  final double netProfit;
  final int paidCustomersCount;
  final int unpaidCustomersCount;
}

class AppProvider extends ChangeNotifier {
  AppProvider({
    required LocalDatabaseService database,
    required SettingsService settingsService,
    HistoryService? historyService,
    Uuid? uuid,
  })  : _database = database,
        _settingsService = settingsService,
        _historyService = historyService ?? HistoryService(),
        _uuid = uuid ?? const Uuid();

  static const int maxCustomersPerGroup = 6;

  final LocalDatabaseService _database;
  final SettingsService _settingsService;
  final HistoryService _historyService;
  final Uuid _uuid;

  List<PackageGroup> _groups = <PackageGroup>[];
  List<Customer> _customers = <Customer>[];
  List<MonthlyHistory> _history = <MonthlyHistory>[];
  bool _isReady = false;
  bool _isBusy = false;
  String? _error;

  List<PackageGroup> get groups => List.unmodifiable(_groups);
  List<Customer> get customers => List.unmodifiable(_customers);
  List<MonthlyHistory> get history => List.unmodifiable(_history);
  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  String? get error => _error;

  DashboardSummary get dashboardSummary {
    final summaries = _groups.map((group) => summaryForGroup(group.id)).toList();
    return DashboardSummary(
      totalCollected: summaries.fold(0, (sum, item) => sum + item.totalCollected),
      totalPending: summaries.fold(0, (sum, item) => sum + item.totalPending),
      totalExpectedSales:
          summaries.fold(0, (sum, item) => sum + item.totalExpectedSales),
      companyCosts: summaries.fold(0, (sum, item) => sum + item.companyCost),
      netProfit: summaries.fold(0, (sum, item) => sum + item.netProfit),
      paidCustomersCount: summaries.fold(0, (sum, item) => sum + item.paidCount),
      unpaidCustomersCount:
          summaries.fold(0, (sum, item) => sum + item.unpaidCount),
    );
  }

  double? get previousDashboardNetProfit {
    if (_history.isEmpty) {
      return null;
    }
    final latestStart = _history.first.cycleStartDate;
    final latestRecords = _history.where(
      (item) => AppDateUtils.isSameDate(item.cycleStartDate, latestStart),
    );
    return latestRecords.fold<double>(0, (sum, item) => sum + item.netProfit);
  }

  Future<void> initialize() async {
    _isReady = false;
    _error = null;
    notifyListeners();

    try {
      await _ensureFirstLaunchData();
      _loadFromDatabase();
      await checkMonthlyReset();
      _loadFromDatabase();
      _isReady = true;
    } catch (error, stackTrace) {
      debugPrint('Initialization error: $error\n$stackTrace');
      _error = error.toString();
    }

    notifyListeners();
  }

  PackageGroup? groupById(String groupId) {
    for (final group in _groups) {
      if (group.id == groupId) {
        return group;
      }
    }
    return null;
  }

  MonthlyHistory? historyById(String historyId) {
    for (final item in _history) {
      if (item.id == historyId) {
        return item;
      }
    }
    return null;
  }

  List<Customer> activeCustomersForGroup(String groupId) {
    return _customers
        .where((customer) => customer.groupId == groupId && customer.isActive)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  GroupFinancialSummary summaryForGroup(String groupId) {
    final group = groupById(groupId);
    final groupCustomers = activeCustomersForGroup(groupId);
    final paidCustomers = groupCustomers.where((customer) => customer.isPaid);
    final unpaidCustomers = groupCustomers.where((customer) => !customer.isPaid);
    final collected = paidCustomers.fold<double>(
      0,
      (sum, customer) => sum + customer.price,
    );
    final pending = unpaidCustomers.fold<double>(
      0,
      (sum, customer) => sum + customer.price,
    );
    final companyCost = group?.currentCompanyCost ?? 0;

    return GroupFinancialSummary(
      totalCollected: collected,
      totalPending: pending,
      totalExpectedSales: collected + pending,
      companyCost: companyCost,
      netProfit: collected - companyCost,
      paidCount: paidCustomers.length,
      unpaidCount: unpaidCustomers.length,
      customerCount: groupCustomers.length,
    );
  }

  bool canAddCustomer(String groupId) {
    return activeCustomersForGroup(groupId).length < maxCustomersPerGroup;
  }

  Future<bool> addCustomer({
    required String groupId,
    required String name,
    required String phone,
    required double gigabytes,
    required double price,
    required bool isPaid,
    required String notes,
  }) async {
    if (!canAddCustomer(groupId)) {
      return false;
    }

    final now = DateTime.now();
    final customer = Customer(
      id: _uuid.v4(),
      groupId: groupId,
      name: name.trim(),
      phone: phone.trim(),
      gigabytes: gigabytes,
      price: price,
      isPaid: isPaid,
      lastPaidDate: isPaid ? now : null,
      notes: notes.trim(),
      isActive: true,
    );

    await _database.saveCustomer(customer);
    _loadFromDatabase();
    notifyListeners();
    return true;
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    final normalized = updatedCustomer.copyWith(
      name: updatedCustomer.name.trim(),
      phone: updatedCustomer.phone.trim(),
      notes: updatedCustomer.notes.trim(),
      lastPaidDate: updatedCustomer.isPaid
          ? (updatedCustomer.lastPaidDate ?? DateTime.now())
          : null,
    );
    await _database.saveCustomer(normalized);
    _loadFromDatabase();
    notifyListeners();
  }

  Future<void> markCustomerPaid(String customerId) async {
    final customer = _customers.firstWhere((item) => item.id == customerId);
    await _database.saveCustomer(
      customer.copyWith(isPaid: true, lastPaidDate: DateTime.now()),
    );
    _loadFromDatabase();
    notifyListeners();
  }

  Future<void> markCustomerUnpaid(String customerId) async {
    final customer = _customers.firstWhere((item) => item.id == customerId);
    await _database.saveCustomer(
      customer.copyWith(isPaid: false, lastPaidDate: null),
    );
    _loadFromDatabase();
    notifyListeners();
  }

  Future<void> deleteCustomer(String customerId) async {
    final customer = _customers.firstWhere((item) => item.id == customerId);
    await _database.saveCustomer(
      customer.copyWith(isActive: false, isPaid: false, lastPaidDate: null),
    );
    _loadFromDatabase();
    notifyListeners();
  }

  Future<void> updateGroupSettings({
    required String groupId,
    required String name,
    required int renewalDay,
    required double companyCost,
  }) async {
    final group = groupById(groupId);
    if (group == null) {
      return;
    }
    if (renewalDay != 1 && renewalDay != 16) {
      throw ArgumentError.value(renewalDay, 'renewalDay', 'Must be 1 or 16');
    }

    final currentCycleStart = CycleService.getCurrentCycleStartDate(
      renewalDay,
      DateTime.now(),
    );

    final updated = group.copyWith(
      name: name.trim(),
      renewalDay: renewalDay,
      currentCompanyCost: companyCost,
      currentCycleStartDate: currentCycleStart,
      lastResetCycleStartDate: currentCycleStart,
    );

    await _database.saveGroup(updated);
    _loadFromDatabase();
    notifyListeners();
  }

  Future<void> resetDemoData() async {
    _isBusy = true;
    notifyListeners();
    await _database.clearBusinessData();
    await _settingsService.setDemoDataCreated(false);
    await _ensureFirstLaunchData();
    _loadFromDatabase();
    _isBusy = false;
    notifyListeners();
  }

  Future<void> checkMonthlyReset() async {
    final today = DateTime.now();

    for (final group in List<PackageGroup>.from(_groups)) {
      final currentCycleStart = CycleService.getCurrentCycleStartDate(
        group.renewalDay,
        today,
      );

      // Monthly reset is intentionally tied to lastResetCycleStartDate.
      // Once a new cycle start date is detected, we save one immutable
      // history snapshot, reset payment flags, then store the new start date.
      // Because lastResetCycleStartDate is updated immediately, the same
      // cycle cannot be reset twice on later app launches.
      if (!AppDateUtils.isSameDate(
        currentCycleStart,
        group.lastResetCycleStartDate,
      )) {
        final groupCustomers = activeCustomersForGroup(group.id);
        final previousCycleStart = group.lastResetCycleStartDate;
        final previousCycleEnd = CycleService.getCycleEndDate(
          previousCycleStart,
          group.renewalDay,
        );

        final previousGroup = group.copyWith(
          currentCycleStartDate: previousCycleStart,
        );
        final historyRecord = _historyService.createMonthlyHistory(
          group: previousGroup,
          activeCustomers: groupCustomers,
          cycleStartDate: previousCycleStart,
          cycleEndDate: previousCycleEnd,
        );
        await _database.saveHistory(historyRecord);

        for (final customer in groupCustomers) {
          await _database.saveCustomer(
            customer.copyWith(isPaid: false, lastPaidDate: null),
          );
        }

        await _database.saveGroup(
          group.copyWith(
            currentCycleStartDate: currentCycleStart,
            lastResetCycleStartDate: currentCycleStart,
          ),
        );
      }
    }
  }

  Future<void> _ensureFirstLaunchData() async {
    if (_settingsService.getDemoDataCreated()) {
      return;
    }

    final today = DateTime.now();
    final groups = <PackageGroup>[
      PackageGroup.defaultGroup(
        index: 1,
        today: today,
        companyCost: 720,
        renewalDay: 1,
      ),
      PackageGroup.defaultGroup(
        index: 2,
        today: today,
        companyCost: 650,
        renewalDay: 16,
      ),
      PackageGroup.defaultGroup(
        index: 3,
        today: today,
        companyCost: 0,
        renewalDay: 1,
      ),
    ];

    final demoCustomers = <Customer>[
      Customer(
        id: _uuid.v4(),
        groupId: 'group_1',
        name: 'Ahmed Ali',
        phone: '01500000001',
        gigabytes: 140,
        price: 180,
        isPaid: true,
        lastPaidDate: today,
        notes: '',
        isActive: true,
      ),
      Customer(
        id: _uuid.v4(),
        groupId: 'group_1',
        name: 'Mona Hassan',
        phone: '01500000002',
        gigabytes: 100,
        price: 150,
        isPaid: false,
        lastPaidDate: null,
        notes: '',
        isActive: true,
      ),
      Customer(
        id: _uuid.v4(),
        groupId: 'group_2',
        name: 'Omar Samir',
        phone: '01500000003',
        gigabytes: 200,
        price: 230,
        isPaid: true,
        lastPaidDate: today,
        notes: '',
        isActive: true,
      ),
      Customer(
        id: _uuid.v4(),
        groupId: 'group_2',
        name: 'Sara Adel',
        phone: '01500000004',
        gigabytes: 140,
        price: 180,
        isPaid: false,
        lastPaidDate: null,
        notes: '',
        isActive: true,
      ),
    ];

    await _database.saveGroups(groups);
    await _database.saveCustomers(demoCustomers);
    await _settingsService.setDemoDataCreated(true);
  }

  void _loadFromDatabase() {
    _groups = _database.getGroups();
    _customers = _database.getCustomers();
    _history = _database.getHistory();
  }
}
