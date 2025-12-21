import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/firebase/auth_service.dart';

class PetitionCreatorPage extends StatefulWidget {
  const PetitionCreatorPage({super.key});

  @override
  State<PetitionCreatorPage> createState() => _PetitionCreatorPageState();
}

class _PetitionCreatorPageState extends State<PetitionCreatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _repository = PetitionRepository.create();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _createPetition() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = authService.value.currentUser;
    if (currentUser == null) {
      showErrorSnackBar(context.l10n.pleaseSignInFirst);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse tags from comma-separated input
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Create the petition object
      final petition = Petition(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        signatureCount: 0,
        createdBy: currentUser.uid,
        createdAt: DateTime.now(),
      );

      // Save to Firestore using toFirestore
      final petitionId = await _repository.createPetition(petition);

      if (mounted) {
        showSuccessSnackBar(context.l10n.createdPetition + petitionId);

        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        _tagsController.clear();
        _formKey.currentState!.reset();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context.l10n.errorCreatingPetition + e.toString());
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
      appBar: AppBar(title: Text(context.l10n.createPetition)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.l10n.title,
                  hintText: context.l10n.enterTitle,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.titleRequired;
                  }
                  if (value.trim().length < 5) {
                    return context.l10n.titleTooShort;
                  }
                  return null;
                },
                maxLength: 100,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                  hintText: context.l10n.enterDescription,
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.descriptionRequired;
                  }
                  if (value.trim().length < 20) {
                    return context.l10n.descriptionTooShort;
                  }
                  return null;
                },
                maxLength: 1000,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: context.l10n.tags,
                  hintText: context.l10n.tagsHint,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.tagsRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _createPetition,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        context.l10n.createPetition,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
