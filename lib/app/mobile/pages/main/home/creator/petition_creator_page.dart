import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/data/services/publishing_quota_service.dart';
import 'package:stimmapp/core/data/services/storage_service.dart';

class PetitionCreatorPage extends StatefulWidget {
  const PetitionCreatorPage({super.key});

  @override
  State<PetitionCreatorPage> createState() => _PetitionCreatorPageState();
}

class _PetitionCreatorPageState extends State<PetitionCreatorPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _repository = PetitionRepository.create();
  bool _isLoading = false;
  bool _isStateDependent = false;
  XFile? _imageFile;
  bool _isUploading = false;
  UserProfile? _user;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      final user = await UserRepository.create()
          .watchById(currentUser.uid)
          .first;
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<String?> _uploadImageForUser(String uid) async {
    if (_imageFile == null) {
      return null;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final storage = StorageService(FirebaseStorage.instance);
      final fileName = '${DateTime.now().toIso8601String()}.jpg';
      final bytes = await _imageFile!.readAsBytes();
      final downloadUrl = await storage.uploadUserBytes(
        uid,
        'petition_images/$fileName',
        bytes,
        contentType: 'image/jpeg',
      );
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context.l10n.errorUploadingImage + e.toString());
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _createPetition(FormState form) async {
    if (!form.validate()) {
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
      String? imageUrl;
      if (_imageFile != null) {
        // upload to the authenticated user's area so storage.rules allow the write
        imageUrl = await _uploadImageForUser(currentUser.uid);
        if (imageUrl == null) {
          // Error is already shown in _uploadImageForUser
          return;
        }
      }

      // Parse tags from comma-separated input
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      String? state;
      if (_isStateDependent) {
        final userProfile = await UserRepository.create().getById(
          currentUser.uid,
        );
        state = userProfile?.state;
      }

      // Create the petition object
      final now = DateTime.now();
      final petition = Petition(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        signatureCount: 0,
        createdBy: currentUser.uid,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 28)),
        status: IConst.active,
        state: state,
        imageUrl: imageUrl,
      );

      List<Petition> matchedTitles = await _repository
          .list(query: petition.title, status: "active")
          .first;
      String matchedTitle = matchedTitles.isNotEmpty
          ? matchedTitles.first.title
          : '';
      if (matchedTitle.isNotEmpty && matchedTitle == petition.title) {
        showErrorSnackBar('petition title in use already');
        return;
      }

      // Enforce daily quota atomically
      await PublishingQuotaService.instance.incrementPetition();

      // Save to Firestore using toFirestore
      final petitionId = await _repository.createPetition(petition);

      if (mounted) {
        showSuccessSnackBar(context.l10n.createdPetition + petitionId);

        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        _tagsController.clear();
        setState(() {
          _imageFile = null;
        });
        form.reset();
      }
    } on StateError catch (e) {
      if (mounted) {
        if (e.message == 'petition_daily_limit_reached') {
          showErrorSnackBar(context.l10n.dailyCreateLimitReached);
        } else {
          showErrorSnackBar(context.l10n.errorCreatingPetition + e.toString());
        }
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
        Navigator.of(context).pop();
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
          child: ListView(
            children: [
              const SizedBox(height: 30),
              if (_user?.isPro == true) ...[
                if (_imageFile != null)
                  FutureBuilder<List<int>>(
                    future: _imageFile!.readAsBytes().then(
                      (bytes) => List<int>.from(bytes),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(Uint8List.fromList(snapshot.data!));
                      }
                      return const CircularProgressIndicator();
                    },
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(context.l10n.addImage),
                  ),
                const SizedBox(height: 20),
              ],
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: _isLoading || _isUploading
                        ? null
                        : () {
                            final form = Form.of(context);
                            _createPetition(form);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading || _isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            context.l10n.createPetition,
                            style: const TextStyle(fontSize: 16),
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
