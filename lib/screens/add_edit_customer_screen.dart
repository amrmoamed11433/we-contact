import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/customer_model.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

class AddEditCustomerScreen extends StatefulWidget {
  const AddEditCustomerScreen({
    super.key,
    required this.groupId,
    this.customerId,
  });

  final String groupId;
  final String? customerId;

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gigabytesController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  Customer? _editingCustomer;
  bool _isPaid = false;
  bool _isSaving = false;
  bool _isPickingContact = false;

  bool get _isEditing => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCustomer());
  }

  void _loadCustomer() {
    if (!_isEditing) {
      return;
    }
    final provider = context.read<AppProvider>();
    final groupCustomers = provider.activeCustomersForGroup(widget.groupId);
    for (final customer in groupCustomers) {
      if (customer.id == widget.customerId) {
        _editingCustomer = customer;
        _nameController.text = customer.name;
        _phoneController.text = customer.phone;
        _gigabytesController.text = _numberText(customer.gigabytes);
        _priceController.text = _numberText(customer.price);
        _notesController.text = customer.notes;
        _isPaid = customer.isPaid;
        setState(() {});
        return;
      }
    }
  }

  String _numberText(double value) {
    return value.truncateToDouble() == value
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _gigabytesController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCustomer : l10n.addCustomer),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _ContactImportCard(
                title: l10n.pickFromContacts,
                description: l10n.pickFromContactsDescription,
                buttonLabel: l10n.pickFromContacts,
                isLoading: _isPickingContact,
                onPressed: _isPickingContact ? null : _pickContact,
              ),
              const SizedBox(height: 18),
              _TextFieldLabel(label: l10n.customerName),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: l10n.nameHint),
                validator: (value) => Validators.requiredText(
                  value,
                  l10n.requiredField,
                ),
              ),
              const SizedBox(height: 16),
              _TextFieldLabel(label: l10n.phoneNumber),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: l10n.phoneHint),
                validator: (value) => Validators.requiredText(
                  value,
                  l10n.requiredField,
                ),
              ),
              const SizedBox(height: 16),
              _TextFieldLabel(label: l10n.gigabytes),
              TextFormField(
                controller: _gigabytesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: l10n.gigabytesHint),
                validator: (value) => Validators.positiveNumber(
                  value,
                  l10n.requiredField,
                  l10n.invalidNumber,
                  l10n.mustBeGreaterThanZero,
                ),
              ),
              const SizedBox(height: 16),
              _TextFieldLabel(label: l10n.price),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: l10n.priceHint),
                validator: (value) => Validators.nonNegativeNumber(
                  value,
                  l10n.requiredField,
                  l10n.invalidNumber,
                  l10n.mustBeZeroOrMore,
                ),
              ),
              const SizedBox(height: 16),
              _TextFieldLabel(label: l10n.notesOptional),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(hintText: l10n.notes),
              ),
              const SizedBox(height: 20),
              _TextFieldLabel(label: l10n.paymentStatus),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.paid),
                    icon: const Icon(Icons.check_circle_rounded),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.unpaid),
                    icon: const Icon(Icons.pending_rounded),
                  ),
                ],
                selected: {_isPaid},
                onSelectionChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _isPaid = value.first);
                },
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

  Future<void> _pickContact() async {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.selectionClick();
    setState(() => _isPickingContact = true);

    try {
      var permissionStatus =
          await FlutterContacts.permissions.check(PermissionType.read);
      if (permissionStatus != PermissionStatus.granted) {
        permissionStatus =
            await FlutterContacts.permissions.request(PermissionType.read);
      }

      if (!mounted) {
        return;
      }

      if (permissionStatus != PermissionStatus.granted) {
        setState(() => _isPickingContact = false);
        await _showContactsPermissionDialog();
        return;
      }

      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone},
      );

      if (!mounted) {
        return;
      }

      final options = _buildContactOptions(contacts, l10n);
      setState(() => _isPickingContact = false);

      if (options.isEmpty) {
        _showSnack(l10n.noContactsWithPhones);
        return;
      }

      final selected = await showModalBottomSheet<_ContactPhoneOption>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => _ContactsPickerSheet(
          options: options,
          title: l10n.contacts,
          searchHint: l10n.searchContacts,
          noResultsText: l10n.noContactsWithPhones,
          selectLabel: l10n.selectContact,
        ),
      );

      if (!mounted || selected == null) {
        return;
      }

      _nameController.text = selected.name;
      _phoneController.text = selected.phoneForField;
      _showSnack(l10n.contactImported);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isPickingContact = false);
      _showSnack(l10n.contactsReadError);
    }
  }

  List<_ContactPhoneOption> _buildContactOptions(
    List<Contact> contacts,
    AppLocalizations l10n,
  ) {
    final seen = <String>{};
    final options = <_ContactPhoneOption>[];

    for (final contact in contacts) {
      final name = _contactName(contact, l10n);
      for (final phone in contact.phones) {
        final rawPhone = phone.number.trim();
        if (rawPhone.isEmpty) {
          continue;
        }
        final phoneForField = _phoneForField(rawPhone);
        final key = '${name.toLowerCase()}|$phoneForField';
        if (!seen.add(key)) {
          continue;
        }
        options.add(
          _ContactPhoneOption(
            name: name,
            phoneDisplay: rawPhone,
            phoneForField: phoneForField,
          ),
        );
      }
    }

    options.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return options;
  }

  String _contactName(Contact contact, AppLocalizations l10n) {
    final String? rawDisplayName = contact.displayName;
    final displayName = rawDisplayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final Name? name = contact.name;
    if (name != null) {
      final pieces = [
        name.prefix,
        name.first,
        name.middle,
        name.last,
        name.suffix,
      ]
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join(' ');
      if (pieces.isNotEmpty) {
        return pieces;
      }
    }

    return l10n.unnamedContact;
  }

  String _phoneForField(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  Future<void> _showContactsPermissionDialog() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactsPermissionTitle),
        content: Text(l10n.contactsPermissionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FlutterContacts.permissions.openSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      _showSnack(l10n.invalidFormTitle);
      return;
    }

    final provider = context.read<AppProvider>();
    if (!_isEditing && !provider.canAddCustomer(widget.groupId)) {
      await showDialog<void>(
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

    setState(() => _isSaving = true);
    final gigabytes = Validators.parseLocalizedDouble(_gigabytesController.text)!;
    final price = Validators.parseLocalizedDouble(_priceController.text)!;

    if (_isEditing && _editingCustomer != null) {
      await provider.updateCustomer(
        _editingCustomer!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          gigabytes: gigabytes,
          price: price,
          isPaid: _isPaid,
          lastPaidDate: _isPaid ? _editingCustomer!.lastPaidDate : null,
          notes: _notesController.text.trim(),
        ),
      );
    } else {
      await provider.addCustomer(
        groupId: widget.groupId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        gigabytes: gigabytes,
        price: price,
        isPaid: _isPaid,
        notes: _notesController.text.trim(),
      );
    }

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    _showSnack(l10n.customerSaved);
    Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ContactImportCard extends StatelessWidget {
  const _ContactImportCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.primary.withOpacity(0.16)),
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
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.contacts_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF171717),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_search_rounded),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactsPickerSheet extends StatefulWidget {
  const _ContactsPickerSheet({
    required this.options,
    required this.title,
    required this.searchHint,
    required this.noResultsText,
    required this.selectLabel,
  });

  final List<_ContactPhoneOption> options;
  final String title;
  final String searchHint;
  final String noResultsText;
  final String selectLabel;

  @override
  State<_ContactsPickerSheet> createState() => _ContactsPickerSheetState();
}

class _ContactsPickerSheetState extends State<_ContactsPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final filteredOptions = query.isEmpty
        ? widget.options
        : widget.options
            .where(
              (option) => option.searchText.contains(query),
            )
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredOptions.isEmpty
                    ? Center(
                        child: Text(
                          widget.noResultsText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filteredOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final option = filteredOptions[index];
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.of(context).pop(option);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE8EAF0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text(option.initial),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            option.phoneDisplay,
                                            textDirection: TextDirection.ltr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: const Color(0xFF6B7280),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        Navigator.of(context).pop(option);
                                      },
                                      child: Text(widget.selectLabel),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactPhoneOption {
  const _ContactPhoneOption({
    required this.name,
    required this.phoneDisplay,
    required this.phoneForField,
  });

  final String name;
  final String phoneDisplay;
  final String phoneForField;

  String get sortKey => '${name.toLowerCase()}|$phoneForField';
  String get searchText => '$name $phoneDisplay $phoneForField'.toLowerCase();

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.characters.first.toUpperCase();
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
