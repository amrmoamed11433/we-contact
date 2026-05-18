import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/group_model.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

class EditGroupScreen extends StatefulWidget {
  const EditGroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyCostController = TextEditingController();
  int _renewalDay = 1;
  bool _isLoaded = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      final provider = context.read<AppProvider>();
      final group = provider.groupById(widget.groupId);
      if (group != null) {
        _loadGroup(group);
      }
      _isLoaded = true;
    }
  }

  void _loadGroup(PackageGroup group) {
    _nameController.text = group.name;
    _companyCostController.text = _numberText(group.currentCompanyCost);
    _renewalDay = group.renewalDay;
  }

  String _numberText(double value) {
    return value.truncateToDouble() == value
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editGroup)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _TextFieldLabel(label: l10n.groupName),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.requiredText(
                  value,
                  l10n.requiredField,
                ),
              ),
              const SizedBox(height: 18),
              _TextFieldLabel(label: l10n.renewalDay),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 1, label: Text(l10n.renewalDayValue(1))),
                  ButtonSegment(value: 16, label: Text(l10n.renewalDayValue(16))),
                ],
                selected: {_renewalDay},
                onSelectionChanged: (selection) {
                  HapticFeedback.selectionClick();
                  setState(() => _renewalDay = selection.first);
                },
              ),
              const SizedBox(height: 18),
              _TextFieldLabel(label: l10n.companyCost),
              TextFormField(
                controller: _companyCostController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(helperText: l10n.companyCostHelp),
                validator: (value) => Validators.nonNegativeNumber(
                  value,
                  l10n.requiredField,
                  l10n.invalidNumber,
                  l10n.mustBeZeroOrMore,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.profitFormula,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF7B8190),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidFormTitle)),
      );
      return;
    }

    if (_renewalDay != 1 && _renewalDay != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidRenewalDay)),
      );
      return;
    }

    setState(() => _isSaving = true);
    await context.read<AppProvider>().updateGroupSettings(
          groupId: widget.groupId,
          name: _nameController.text,
          renewalDay: _renewalDay,
          companyCost:
              Validators.parseLocalizedDouble(_companyCostController.text)!,
        );

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.groupSaved)),
    );
    Navigator.of(context).pop();
  }
}

class _TextFieldLabel extends StatelessWidget {
  const _TextFieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF374151),
            ),
      ),
    );
  }
}
