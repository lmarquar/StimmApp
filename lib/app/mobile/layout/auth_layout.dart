import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/others/app_loading_page.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/services/auth_service.dart';
import 'package:stimmapp/app/mobile/pages/main/onboarding/welcome_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/widget_tree.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:stimmapp/core/services/profile_picture_service.dart';
import 'package:stimmapp/app/mobile/pages/others/delete_account_page.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/main.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/change_profile_picture_page.dart';

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
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authServiceValue, child) {
        return StreamBuilder(
          stream: authServiceValue.authStateChanges,
          builder: (context, snapshot) {
            Widget content;
            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const AppLoadingPage();
            } else if (snapshot.hasData) {
              final user = snapshot.data as dynamic; // firebase User
              final uid = user.uid as String?;

              // start or reuse ensureFuture for this user
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
                                      authService.value.currentUser;
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
                                      authService.value.currentUser;
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
                                  await authService.value.signOut();
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
      final authPhoto = authService.value.currentUser?.photoURL;
      final profileUrl =
          ProfilePictureService.instance.profileUrlNotifier.value;
      if (authPhoto != null || profileUrl != null) return true;

      // Attempt to upload default avatar from assets
      try {
        final bytes = await rootBundle.load('assets/images/default_avatar.png');
        final Uint8List list = bytes.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final tmpFile = File('${tempDir.path}/default_avatar.png');
        await tmpFile.writeAsBytes(list, flush: true);

        await ProfilePictureService.instance.uploadProfilePicture(
          uid,
          tmpFile,
          onProgress: (p) {
            // optional: could show small progress via snackbar or notifier
          },
        );

        // best-effort set FirebaseAuth photo URL (non-blocking)
        try {
          final url = ProfilePictureService.instance.profileUrlNotifier.value;
          if (url != null) {
            await authService.value.currentUser?.updatePhotoURL(url);
            await authService.value.currentUser?.reload();
          }
        } catch (e) {
          debugPrint('Could not update auth photoURL: $e');
        }

        try {
          await tmpFile.delete();
        } catch (_) {}

        // re-check
        final newProfileUrl =
            ProfilePictureService.instance.profileUrlNotifier.value;
        return newProfileUrl != null ||
            authService.value.currentUser?.photoURL != null;
      } catch (e, st) {
        debugPrint('Auto default avatar upload failed: $e\n$st');
        // show a short message to the user
        if (navigatorKey.currentContext != null) {
          showErrorSnackBar('Could not create a default profile picture.');
        }
        return false;
      }
    } catch (e, st) {
      debugPrint('Profile validation error: $e\n$st');
      return false;
    }
  }
}
