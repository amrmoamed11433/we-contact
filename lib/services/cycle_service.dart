class CycleService {
  const CycleService._();

  static DateTime getCurrentCycleStartDate(int renewalDay, DateTime today) {
    _assertValidRenewalDay(renewalDay);
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (renewalDay == 1) {
      return DateTime(normalizedToday.year, normalizedToday.month, 1);
    }

    if (normalizedToday.day >= 16) {
      return DateTime(normalizedToday.year, normalizedToday.month, 16);
    }

    return DateTime(normalizedToday.year, normalizedToday.month - 1, 16);
  }

  static DateTime getNextCycleStartDate(int renewalDay, DateTime today) {
    _assertValidRenewalDay(renewalDay);
    final currentStart = getCurrentCycleStartDate(renewalDay, today);
    return DateTime(currentStart.year, currentStart.month + 1, renewalDay);
  }

  static DateTime getCycleEndDate(DateTime cycleStartDate, int renewalDay) {
    _assertValidRenewalDay(renewalDay);
    final nextStart = DateTime(
      cycleStartDate.year,
      cycleStartDate.month + 1,
      renewalDay,
    );
    return nextStart.subtract(const Duration(days: 1));
  }

  static void _assertValidRenewalDay(int renewalDay) {
    if (renewalDay != 1 && renewalDay != 16) {
      throw ArgumentError.value(renewalDay, 'renewalDay', 'Must be 1 or 16');
    }
  }
}
