import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/customer_model.dart';
import '../providers/app_provider.dart';
import '../services/cycle_service.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/customer_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import 'add_edit_customer_screen.dart';
import 'edit_group_screen.dart';

class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final group = provider.groupById(groupId);
            return Text(group?.name ?? l10n.groups);
          },
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditGroupScreen(groupId: groupId)),
            ),
            icon: const Icon(Icons.edit_rounded),
            tooltip: l10n.editGroup,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddCustomer(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final group = provider.groupById(groupId);
            if (group == null) {
              return EmptyState(
                icon: Icons.groups_rounded,
                title: l10n.empty,
                subtitle: l10n.errorLoadingData,
              );
            }

            final customers = provider.activeCustomersForGroup(groupId);
            final summary = provider.summaryForGroup(groupId);
            final cycleEnd = CycleService.getCycleEndDate(
              group.currentCycleStartDate,
              group.renewalDay,
            );

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _CycleHeader(
                          groupName: group.name,
                          renewalDay: l10n.renewalDayValue(group.renewalDay),
                          cycleDates: l10n.cycleDates(
                            AppDateUtils.formatShortDate(
                              group.currentCycleStartDate,
                              localeCode,
                            ),
                            AppDateUtils.formatShortDate(cycleEnd, localeCode),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.cycleResetNote,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF7B8190),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 18),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.12,
                          children: [
                            SummaryCard(
                              label: l10n.collected,
                              value: CurrencyUtils.formatCurrency(
                                summary.totalCollected,
                                localeCode,
                                l10n.egp,
                              ),
                              icon: Icons.payments_rounded,
                              accentColor: const Color(0xFF16A34A),
                            ),
                            SummaryCard(
                              label: l10n.pending,
                              value: CurrencyUtils.formatCurrency(
                                summary.totalPending,
                                localeCode,
                                l10n.egp,
                              ),
                              icon: Icons.pending_actions_rounded,
                              accentColor: const Color(0xFFF59E0B),
                            ),
                            SummaryCard(
                              label: l10n.companyCost,
                              value: CurrencyUtils.formatCurrency(
                                summary.companyCost,
                                localeCode,
                                l10n.egp,
                              ),
                              icon: Icons.receipt_long_rounded,
                              accentColor: const Color(0xFF64748B),
                            ),
                            SummaryCard(
                              label: l10n.netProfit,
                              value: CurrencyUtils.formatCurrency(
                                summary.netProfit,
                                localeCode,
                                l10n.egp,
                              ),
                              icon: Icons.trending_up_rounded,
                              accentColor: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.customers,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            Text(
                              l10n.customersCount(
                                summary.customerCount,
                                AppProvider.maxCustomersPerGroup,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF7B8190),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (customers.isEmpty)
                          EmptyState(
                            icon: Icons.person_add_alt_1_rounded,
                            title: l10n.noCustomersYet,
                            subtitle: l10n.addFirstCustomer,
                            actionLabel: l10n.addCustomer,
                            onAction: () => _handleAddCustomer(context),
                          )
                        else
                          ...customers.map(
                            (customer) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DismissibleCustomerCard(
                                customer: customer,
                                onEdit: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddEditCustomerScreen(
                                      groupId: groupId,
                                      customerId: customer.id,
                                    ),
                                  ),
                                ),
                                onDelete: () => _confirmDeleteCustomer(
                                  context,
                                  customer,
                                ),
                                onTogglePaid: () => _togglePaid(context, customer),
                                onSwipePaid: () async {
                                  await provider.markCustomerPaid(customer.id);
                                  _showSnack(context, l10n.customerPaid);
                                },
                                onSwipeDelete: () => _confirmDeleteCustomer(
                                  context,
                                  customer,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleAddCustomer(BuildContext context) {
    final provider = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context);
    if (!provider.canAddCustomer(groupId)) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.groupFullTitle),
          content: Text(l10n.groupFullMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditCustomerScreen(groupId: groupId),
      ),
    );
  }

  Future<void> _togglePaid(BuildContext context, Customer customer) async {
    final provider = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context);
    if (customer.isPaid) {
      await provider.markCustomerUnpaid(customer.id);
      _showSnack(context, l10n.customerUnpaid);
    } else {
      await provider.markCustomerPaid(customer.id);
      _showSnack(context, l10n.customerPaid);
    }
  }

  Future<void> _confirmDeleteCustomer(
    BuildContext context,
    Customer customer,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCustomerTitle),
        content: Text(l10n.deleteCustomerMessage(customer.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AppProvider>().deleteCustomer(customer.id);
      _showSnack(context, l10n.customerDeleted);
    }
  }

  void _showSnack(BuildContext context, String message) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CycleHeader extends StatelessWidget {
  const _CycleHeader({
    required this.groupName,
    required this.renewalDay,
    required this.cycleDates,
  });

  final String groupName;
  final String renewalDay;
  final String cycleDates;

  @override
  Widget build(BuildContext context) {
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
              Icons.groups_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  renewalDay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7B8190),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  cycleDates,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
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

class _DismissibleCustomerCard extends StatelessWidget {
  const _DismissibleCustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePaid,
    required this.onSwipePaid,
    required this.onSwipeDelete,
  });

  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePaid;
  final Future<void> Function() onSwipePaid;
  final Future<void> Function() onSwipeDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: ValueKey(customer.id),
      background: _SwipeBackground(
        color: const Color(0xFF16A34A),
        icon: Icons.done_all_rounded,
        label: l10n.paidSwipeAction,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBackground(
        color: const Color(0xFFE5484D),
        icon: Icons.delete_rounded,
        label: l10n.deleteSwipeAction,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          await onSwipePaid();
        } else {
          await onSwipeDelete();
        }
        return false;
      },
      child: CustomerCard(
        customer: customer,
        onEdit: onEdit,
        onDelete: onDelete,
        onTogglePaid: onTogglePaid,
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLeft) Text(label, style: _textStyle(context)),
          if (!isLeft) const SizedBox(width: 8),
          Icon(icon, color: Colors.white),
          if (isLeft) const SizedBox(width: 8),
          if (isLeft) Text(label, style: _textStyle(context)),
        ],
      ),
    );
  }

  TextStyle? _textStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        );
  }
}
