import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PollCreatorPage extends StatefulWidget {
  const PollCreatorPage({super.key});

  @override
  State<PollCreatorPage> createState() => _PollCreatorPageState();
}

class _PollCreatorPageState extends State<PollCreatorPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final _repository = PollRepository.create();
  bool _isLoading = false;
  bool _isStateDependent = false;
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 7));
  final _uuid = const Uuid();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: _expiresAt,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (newDate != null) {
      setState(() {
        _expiresAt = newDate;
      });
    }
  }

  Future<void> _createPoll(FormState form) async {
    if (!form.validate()) {
      showErrorSnackBar(context.l10n.error);
      return;
    }

    final currentUser = authService.currentUser;
    if (currentUser == null) {
      showErrorSnackBar(context.l10n.pleaseSignInFirst);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final options = _optionControllers
          .map(
            (controller) =>
                PollOption(id: _uuid.v4(), label: controller.text.trim()),
          )
          .toList();

      String? state;
      if (_isStateDependent) {
        final userProfile = await UserRepository.create().getById(
          currentUser.uid,
        );
        state = userProfile?.state;
      }

      final poll = Poll(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        options: options,
        votes: {for (var option in options) option.id: 0},
        createdBy: currentUser.uid,
        createdAt: DateTime.now(),
        expiresAt: _expiresAt,
        state: state,
      );

      final pollId = await _repository.createPoll(poll);

      if (mounted) {
        showSuccessSnackBar(context.l10n.createdPoll + pollId);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context.l10n.failedToCreatePoll + e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createPoll)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          child: ListView(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.l10n.title,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().isEmpty ?? true)
                    ? context.l10n.titleRequired
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => (v?.trim().isEmpty ?? true)
                    ? context.l10n.descriptioRequired
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: context.l10n.tags,
                  hintText: context.l10n.hintTextTags,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: Text(context.l10n.stateDependent),
                value: _isStateDependent,
                onChanged: (newValue) {
                  setState(() {
                    _isStateDependent = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              ListTile(
                title: Text(context.l10n.expiresOn),
                subtitle: Text(DateFormat.yMMMd().format(_expiresAt)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectExpiryDate(context),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.options,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._optionControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText:
                                context.l10n.option + (index + 1).toString(),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? context.l10n.optionRequired
                              : null,
                        ),
                      ),
                      if (_optionControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeOption(index),
                        ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addOption),
                onPressed: _addOption,
              ),
              const SizedBox(height: 30),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            final form = Form.of(context);
                            _createPoll(form);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : Text(
                            context.l10n.createPoll,
                            style: TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
