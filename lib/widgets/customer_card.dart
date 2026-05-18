import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/customer_model.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePaid,
  });

  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePaid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final statusColor = customer.isPaid
        ? const Color(0xFF16A34A)
        : const Color(0xFFF59E0B);
    final statusBg = customer.isPaid
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFFF7ED);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusBg.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.35)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  customer.isPaid
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      customer.phone,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  customer.isPaid ? l10n.paid : l10n.unpaid,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.network_cell_rounded,
                label: '${CurrencyUtils.formatNumber(customer.gigabytes, localeCode)} ${l10n.gbUnit}',
              ),
              _InfoChip(
                icon: Icons.payments_rounded,
                label: CurrencyUtils.formatCurrency(
                  customer.price,
                  localeCode,
                  l10n.egp,
                ),
              ),
              _InfoChip(
                icon: Icons.event_available_rounded,
                label: customer.lastPaidDate == null
                    ? l10n.notPaidYet
                    : l10n.lastPaid(
                        AppDateUtils.formatShortDate(
                          customer.lastPaidDate!,
                          localeCode,
                        ),
                      ),
              ),
            ],
          ),
          if (customer.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              customer.notes,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onEdit();
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(l10n.edit),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onTogglePaid();
                  },
                  icon: Icon(
                    customer.isPaid
                        ? Icons.remove_done_rounded
                        : Icons.done_all_rounded,
                    size: 18,
                  ),
                  label: Text(
                    customer.isPaid ? l10n.markAsUnpaid : l10n.markAsPaid,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  onDelete();
                },
                icon: const Icon(Icons.delete_rounded),
                color: const Color(0xFFE5484D),
                tooltip: l10n.delete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
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
