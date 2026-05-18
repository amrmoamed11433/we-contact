import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/monthly_history_model.dart';
import '../providers/app_provider.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import 'history_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedGroupId = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final filteredHistory = provider.history.where((item) {
            return _selectedGroupId == 'all' || item.groupId == _selectedGroupId;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Text(
                        l10n.historyTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.historySubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF7B8190),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: _selectedGroupId,
                        decoration: InputDecoration(labelText: l10n.filterByGroup),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(l10n.allGroups),
                          ),
                          ...provider.groups.map(
                            (group) => DropdownMenuItem(
                              value: group.id,
                              child: Text(group.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGroupId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      if (filteredHistory.isEmpty)
                        EmptyState(
                          icon: Icons.history_rounded,
                          title: l10n.noHistoryYet,
                          subtitle: l10n.historyWillAppear,
                        )
                      else
                        ..._buildHistoryWithMonthHeaders(
                          context,
                          filteredHistory,
                          localeCode,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildHistoryWithMonthHeaders(
    BuildContext context,
    List<MonthlyHistory> items,
    String localeCode,
  ) {
    final widgets = <Widget>[];
    String? lastMonth;

    for (final item in items) {
      final month = AppDateUtils.formatMonth(item.cycleStartDate, localeCode);
      if (month != lastMonth) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Text(
              month,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        );
        lastMonth = month;
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HistoryCard(item: item),
        ),
      );
    }

    return widgets;
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final MonthlyHistory item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HistoryDetailsScreen(historyId: item.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.timeline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.groupName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.cycleDates(
                          AppDateUtils.formatShortDate(item.cycleStartDate, localeCode),
                          AppDateUtils.formatShortDate(item.cycleEndDate, localeCode),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF7B8190),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HistoryMetric(
                    label: l10n.totalCollected,
                    value: CurrencyUtils.formatCurrency(
                      item.totalCollected,
                      localeCode,
                      l10n.egp,
                    ),
                    color: const Color(0xFF16A34A),
                  ),
                ),
                Expanded(
                  child: _HistoryMetric(
                    label: l10n.totalPending,
                    value: CurrencyUtils.formatCurrency(
                      item.totalPending,
                      localeCode,
                      l10n.egp,
                    ),
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _HistoryMetric(
                    label: l10n.companyCost,
                    value: CurrencyUtils.formatCurrency(
                      item.companyCost,
                      localeCode,
                      l10n.egp,
                    ),
                    color: const Color(0xFF64748B),
                  ),
                ),
                Expanded(
                  child: _HistoryMetric(
                    label: l10n.netProfit,
                    value: CurrencyUtils.formatCurrency(
                      item.netProfit,
                      localeCode,
                      l10n.egp,
                    ),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsetsDirectional.only(end: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
