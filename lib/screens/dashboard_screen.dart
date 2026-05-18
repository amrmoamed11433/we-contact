import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/currency_utils.dart';
import '../widgets/group_card.dart';
import '../widgets/summary_card.dart';
import 'edit_group_screen.dart';
import 'group_details_screen.dart';
import 'groups_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = <Widget>[
      const DashboardScreen(),
      const GroupsScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];
    final items = <_NavigationItem>[
      _NavigationItem(Icons.dashboard_rounded, l10n.dashboard),
      _NavigationItem(Icons.groups_rounded, l10n.groups),
      _NavigationItem(Icons.history_rounded, l10n.history),
      _NavigationItem(Icons.settings_rounded, l10n.settings),
    ];

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (itemIndex) {
              final item = items[itemIndex];
              final isActive = itemIndex == _index;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _index = itemIndex),
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Flexible(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (!provider.isReady) {
            return Center(child: Text(l10n.loading));
          }

          final summary = provider.dashboardSummary;
          final previousProfit = provider.previousDashboardNetProfit;
          final trendText = _buildTrendText(
            context,
            summary.netProfit,
            previousProfit,
          );

          return RefreshIndicator(
            onRefresh: provider.initialize,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _DashboardHeader(
                          title: l10n.welcome,
                          subtitle: l10n.currentMonthSummary,
                        ),
                        const SizedBox(height: 20),
                        _ProfitCard(
                          label: l10n.netProfit,
                          amount: CurrencyUtils.formatCurrency(
                            summary.netProfit,
                            localeCode,
                            l10n.egp,
                          ),
                          trend: trendText,
                        ),
                        const SizedBox(height: 20),
                        _SummaryGrid(summary: summary),
                        const SizedBox(height: 18),
                        _CustomerStatusRow(summary: summary),
                        const SizedBox(height: 24),
                        Text(
                          l10n.groups,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...provider.groups.map((group) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GroupCard(
                              group: group,
                              summary: provider.summaryForGroup(group.id),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GroupDetailsScreen(groupId: group.id),
                                ),
                              ),
                              onEdit: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditGroupScreen(groupId: group.id),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _buildTrendText(
    BuildContext context,
    double currentProfit,
    double? previousProfit,
  ) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    if (previousProfit == null || previousProfit == 0) {
      return l10n.noPreviousHistory;
    }
    final percent = ((currentProfit - previousProfit) / previousProfit.abs()) * 100;
    final prefix = percent >= 0 ? '+' : '';
    return l10n.trendFromLastMonth(
      '$prefix${CurrencyUtils.formatPercent(percent, localeCode)}',
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF7B8190),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.auto_graph_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _ProfitCard extends StatelessWidget {
  const _ProfitCard({
    required this.label,
    required this.amount,
    required this.trend,
  });

  final String label;
  final String amount;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D5DFB), Color(0xFF4F46E5), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.26),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.82),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.trending_up_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              amount,
              key: ValueKey(amount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            trend,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.86),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.08,
      children: [
        SummaryCard(
          label: l10n.totalCollected,
          value: CurrencyUtils.formatCurrency(summary.totalCollected, localeCode, l10n.egp),
          icon: Icons.payments_rounded,
          accentColor: const Color(0xFF16A34A),
        ),
        SummaryCard(
          label: l10n.totalPending,
          value: CurrencyUtils.formatCurrency(summary.totalPending, localeCode, l10n.egp),
          icon: Icons.pending_actions_rounded,
          accentColor: const Color(0xFFF59E0B),
        ),
        SummaryCard(
          label: l10n.companyCosts,
          value: CurrencyUtils.formatCurrency(summary.companyCosts, localeCode, l10n.egp),
          icon: Icons.receipt_long_rounded,
          accentColor: const Color(0xFF64748B),
        ),
        SummaryCard(
          label: l10n.totalExpectedSales,
          value: CurrencyUtils.formatCurrency(summary.totalExpectedSales, localeCode, l10n.egp),
          icon: Icons.insights_rounded,
          accentColor: const Color(0xFF5B3FFF),
        ),
      ],
    );
  }
}

class _CustomerStatusRow extends StatelessWidget {
  const _CustomerStatusRow({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _StatusChip(
            label: l10n.paidCustomers,
            count: summary.paidCustomersCount,
            color: const Color(0xFF16A34A),
            icon: Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusChip(
            label: l10n.unpaidCustomers,
            count: summary.unpaidCustomersCount,
            color: const Color(0xFFF59E0B),
            icon: Icons.warning_amber_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
