import 'package:hive_flutter/hive_flutter.dart';

import '../models/customer_model.dart';
import '../models/group_model.dart';
import '../models/monthly_history_model.dart';

class LocalDatabaseService {
  static const String groupsBoxName = 'groups';
  static const String customersBoxName = 'customers';
  static const String historyBoxName = 'monthly_history';
  static const String settingsBoxName = 'settings';

  late Box _groupsBox;
  late Box _customersBox;
  late Box _historyBox;
  late Box _settingsBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    await Hive.initFlutter();
    _groupsBox = await Hive.openBox(groupsBoxName);
    _customersBox = await Hive.openBox(customersBoxName);
    _historyBox = await Hive.openBox(historyBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _isInitialized = true;
  }

  List<PackageGroup> getGroups() {
    return _groupsBox.values
        .map((item) => PackageGroup.fromMap(_asMap(item)))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  Future<void> saveGroup(PackageGroup group) async {
    await _groupsBox.put(group.id, group.toMap());
  }

  Future<void> saveGroups(List<PackageGroup> groups) async {
    for (final group in groups) {
      await saveGroup(group);
    }
  }

  List<Customer> getCustomers() {
    return _customersBox.values
        .map((item) => Customer.fromMap(_asMap(item)))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> saveCustomer(Customer customer) async {
    await _customersBox.put(customer.id, customer.toMap());
  }

  Future<void> saveCustomers(List<Customer> customers) async {
    for (final customer in customers) {
      await saveCustomer(customer);
    }
  }

  Future<void> hardDeleteCustomer(String id) async {
    await _customersBox.delete(id);
  }

  List<MonthlyHistory> getHistory() {
    return _historyBox.values
        .map((item) => MonthlyHistory.fromMap(_asMap(item)))
        .toList()
      ..sort((a, b) => b.cycleStartDate.compareTo(a.cycleStartDate));
  }

  Future<void> saveHistory(MonthlyHistory history) async {
    await _historyBox.put(history.id, history.toMap());
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> clearBusinessData() async {
    await _groupsBox.clear();
    await _customersBox.clear();
    await _historyBox.clear();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    return Map<String, dynamic>.from(value as Map);
  }
}
