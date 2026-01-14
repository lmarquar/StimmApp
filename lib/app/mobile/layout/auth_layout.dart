import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/app/mobile/pages/main/home/widget_tree.dart';
import 'package:stimmapp/app/mobile/pages/main/onboarding/welcome_page.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/delete_account_page.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_settings/change_profile_picture_page.dart';
import 'package:stimmapp/app/mobile/pages/others/app_loading_page.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/profile_picture_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';

class AuthLayout extends StatefulWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  Future<bool>? _ensureFuture;
  String? _currentUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        Widget content;
        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const AppLoadingPage();
        } else if (snapshot.hasData) {
              final user = snapshot.data as dynamic;
              final uid = user.uid as String?;
              if (uid != null && uid != _currentUid) {
                _currentUid = uid;
                _ensureFuture = _ensureProfileValid(user, context);
              }

              content = FutureBuilder<bool>(
                future: _ensureFuture,
                builder: (context, fb) {
                  if (fb.connectionState == ConnectionState.waiting) {
                    return const AppLoadingPage();
                  }
                  final ok = fb.data ?? false;
                  if (ok) {
                    return const WidgetTree();
                  }

                  // Recovery UI when profile could not be fixed automatically.
                  return Scaffold(
                    appBar: AppBar(title: Text(context.l10n.myProfile)),
                    body: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your account profile seems incomplete.',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You can retry automatic fix, pick a picture, log out or delete the account.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Retry auto-fix
                                  final currentUser =
                                      authService.currentUser;
                                  if (currentUser != null) {
                                    setState(() {
                                      _ensureFuture = _ensureProfileValid(
                                        currentUser,
                                        context,
                                      );
                                    });
                                  }
                                },
                                child: const Text('Retry'),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  // Let user pick/upload a picture, then re-run the check
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangeProfilePicturePage(),
                                    ),
                                  );
                                  final currentUser =
                                      authService.currentUser;
                                  if (currentUser != null) {
                                    setState(() {
                                      _ensureFuture = _ensureProfileValid(
                                        currentUser,
                                        context,
                                      );
                                    });
                                  }
                                },
                                child: const Text('Choose picture'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  // logout
                                  await authService.signOut();
                                  AppData.isAuthConnected.value = false;
                                },
                                child: Text(context.l10n.logout),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DeleteAccountPage(),
                                    ),
                                  );
                                },
                                child: Text(context.l10n.deleteMyAccount),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              content = widget.pageIfNotConnected ?? const WelcomePage();
            }
            return content;
          },
        );
  }

  // Validate user profile: ensure a profile picture exists (auth photoURL or Firestore).
  // If missing, try to upload the default avatar asset for the user. Return true when
  // the profile is valid (or fixed), false when automatic fix failed.
  Future<bool> _ensureProfileValid(dynamic user, BuildContext context) async {
    try {
      final uid = user.uid as String;
      // Load Firestore-stored profile URL (if any)
      await ProfilePictureService.instance.loadProfileUrl(uid);
      final authPhoto = authService.currentUser?.photoURL;
      final profileUrl =
          ProfilePictureService.instance.profileUrlNotifier.value;
      if (authPhoto != null || profileUrl != null) return true;

      // Attempt to upload default avatar from assets
      try {
        final bytes = await rootBundle.load('assets/images/default_avatar.png');
        final Uint8List list = bytes.buffer.asUint8List();
        final xFile = XFile.fromData(
          list,
          name: 'default_avatar.png',
          mimeType: 'image/png',
        );

        await ProfilePictureService.instance.uploadProfilePicture(
          uid,
          xFile,
          onProgress: (p) {
            // optional: could show small progress via snackbar or notifier
          },
        );
        try {
          final url = ProfilePictureService.instance.profileUrlNotifier.value;
          if (url != null) {
            await authService.currentUser?.updatePhotoURL(url);
            await authService.currentUser?.reload();
          }
        } catch (e) {
          debugPrint('Could not update auth photoURL: $e');
        }
        
        final newProfileUrl =
            ProfilePictureService.instance.profileUrlNotifier.value;
        return newProfileUrl != null ||
            authService.currentUser?.photoURL != null;
      } catch (e, st) {
        debugPrint('Auto default avatar upload failed: $e\n$st');
        return false;
      }
    } catch (e, st) {
      debugPrint('Profile validation error: $e\n$st');
      return false;
    }
  }
}
