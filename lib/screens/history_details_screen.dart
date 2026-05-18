import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/customer_snapshot_model.dart';
import '../models/monthly_history_model.dart';
import '../providers/app_provider.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';

class HistoryDetailsScreen extends StatelessWidget {
  const HistoryDetailsScreen({super.key, required this.historyId});

  final String historyId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyDetails)),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final item = provider.historyById(historyId);
            if (item == null) {
              return EmptyState(
                icon: Icons.history_rounded,
                title: l10n.empty,
                subtitle: l10n.errorLoadingData,
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _HistoryHeader(item: item),
                const SizedBox(height: 14),
                Text(
                  l10n.readOnlyRecord,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF7B8190),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.financialSummary,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.12,
                  children: [
                    SummaryCard(
                      label: l10n.totalCollected,
                      value: CurrencyUtils.formatCurrency(
                        item.totalCollected,
                        localeCode,
                        l10n.egp,
                      ),
                      icon: Icons.payments_rounded,
                      accentColor: const Color(0xFF16A34A),
                    ),
                    SummaryCard(
                      label: l10n.totalPending,
                      value: CurrencyUtils.formatCurrency(
                        item.totalPending,
                        localeCode,
                        l10n.egp,
                      ),
                      icon: Icons.pending_actions_rounded,
                      accentColor: const Color(0xFFF59E0B),
                    ),
                    SummaryCard(
                      label: l10n.companyCost,
                      value: CurrencyUtils.formatCurrency(
                        item.companyCost,
                        localeCode,
                        l10n.egp,
                      ),
                      icon: Icons.receipt_long_rounded,
                      accentColor: const Color(0xFF64748B),
                    ),
                    SummaryCard(
                      label: l10n.netProfit,
                      value: CurrencyUtils.formatCurrency(
                        item.netProfit,
                        localeCode,
                        l10n.egp,
                      ),
                      icon: Icons.trending_up_rounded,
                      accentColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.customerSnapshot,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                ...item.customersSnapshot.map(
                  (snapshot) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SnapshotCard(snapshot: snapshot),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.item});

  final MonthlyHistory item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.history_edu_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.cycleDates(
                    AppDateUtils.formatShortDate(item.cycleStartDate, localeCode),
                    AppDateUtils.formatShortDate(item.cycleEndDate, localeCode),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7B8190),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.snapshot});

  final CustomerSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final color = snapshot.isPaid ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  snapshot.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Text(
                snapshot.isPaid ? l10n.paid : l10n.unpaid,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SnapshotChip(icon: Icons.phone_rounded, label: snapshot.phone),
              _SnapshotChip(
                icon: Icons.network_cell_rounded,
                label: '${CurrencyUtils.formatNumber(snapshot.gigabytes, localeCode)} ${l10n.gbUnit}',
              ),
              _SnapshotChip(
                icon: Icons.payments_rounded,
                label: CurrencyUtils.formatCurrency(
                  snapshot.price,
                  localeCode,
                  l10n.egp,
                ),
              ),
              _SnapshotChip(
                icon: Icons.event_available_rounded,
                label: snapshot.paidDate == null
                    ? l10n.notPaidYet
                    : AppDateUtils.formatShortDate(snapshot.paidDate!, localeCode),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.notes.trim().isEmpty ? l10n.noNotes : snapshot.notes,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotChip extends StatelessWidget {
  const _SnapshotChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
          ),
        ],
      ),
    );
  }
}
