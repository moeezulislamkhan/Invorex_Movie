import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await context.read<AuthProvider>().logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to log out: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Are you sure you want to permanently delete your account?\n\n'
            'Your profile and account data will be removed. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Delete Account',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await context.read<AuthProvider>().deleteAccount();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

  Future<void> _pickProfileImage(
    BuildContext context,
  ) async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (image == null) return;

      final directory =
          await getApplicationDocumentsDirectory();

      final extension =
          image.path.split('.').last;

      final targetPath =
          '${directory.path}/profile_image.$extension';

      final copiedImage =
          await File(image.path).copy(targetPath);

      if (!context.mounted) return;

      await context
          .read<AuthProvider>()
          .setProfileImage(
            copiedImage.path,
          );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile image updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile image: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // REMOVE PROFILE IMAGE
  // ============================================================

  Future<void> _removeProfileImage(
    BuildContext context,
  ) async {
    try {
      final auth = context.read<AuthProvider>();

      final imagePath = auth.profileImagePath;

      if (imagePath != null &&
          imagePath.isNotEmpty) {
        final file = File(imagePath);

        if (await file.exists()) {
          await file.delete();
        }
      }

      await auth.setProfileImage(null);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile image removed successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove profile image: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _showEditProfile(
    BuildContext context,
  ) async {
    final auth = context.read<AuthProvider>();

    final nameController = TextEditingController(
      text: auth.name,
    );

    final emailController = TextEditingController(
      text: auth.email,
    );

    final passwordController =
        TextEditingController();

    bool obscurePassword = true;
    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NAME
                    TextField(
                      controller: nameController,
                      textInputAction:
                          TextInputAction.next,
                      decoration:
                          const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // EMAIL
                    TextField(
                      controller: emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      decoration:
                          const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // NEW PASSWORD
                    TextField(
                      controller:
                          passwordController,
                      obscureText: obscurePassword,
                      textInputAction:
                          TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText:
                            'Leave empty to keep current password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // REMOVE PROFILE IMAGE
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () async {
                                await _removeProfileImage(
                                  context,
                                );

                                if (!dialogContext
                                    .mounted) {
                                  return;
                                }

                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                        ),
                        label: const Text(
                          'Remove Profile Image',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // CANCEL
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.of(
                            dialogContext,
                          ).pop();
                        },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                // SAVE
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name =
                              nameController.text
                                  .trim();

                          final email =
                              emailController.text
                                  .trim();

                          final password =
                              passwordController.text
                                  .trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Name cannot be empty.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Email cannot be empty.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (!email.contains('@')) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid email address.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (password.isNotEmpty &&
                              password.length < 6) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'New password must be at least 6 characters.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            await auth.updateProfile(
                              name: name,
                              email: email,
                              newPassword:
                                  password.isEmpty
                                      ? null
                                      : password,
                            );

                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            Navigator.of(
                              dialogContext,
                            ).pop();

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profile updated successfully.',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst(
                                    'Exception: ',
                                    '',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          30,
        ),
        children: [
          // ======================================================
          // PROFILE CARD
          // ======================================================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(24),
              color:
                  Theme.of(context).brightness ==
                          Brightness.dark
                      ? const Color(0xFF111319)
                      : Colors.white,
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    // PROFILE IMAGE
                    GestureDetector(
                      onTap: () =>
                          _pickProfileImage(
                        context,
                      ),
                      child: Stack(
                        alignment:
                            Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor:
                                Theme.of(context)
                                    .colorScheme
                                    .primary,
                            backgroundImage:
                                auth.profileImagePath !=
                                            null &&
                                        auth.profileImagePath!
                                            .isNotEmpty
                                    ? FileImage(
                                        File(
                                          auth.profileImagePath!,
                                        ),
                                      )
                                    : null,
                            child:
                                auth.profileImagePath ==
                                            null ||
                                        auth.profileImagePath!
                                            .isEmpty
                                    ? Text(
                                        auth.name.isEmpty
                                            ? 'G'
                                            : auth.name[
                                                    0]
                                                .toUpperCase(),
                                        style:
                                            const TextStyle(
                                          fontSize: 26,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
                                      )
                                    : null,
                          ),
                          Container(
                            padding:
                                const EdgeInsets.all(5),
                            decoration:
                                BoxDecoration(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .primary,
                              shape:
                                  BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons
                                  .camera_alt_rounded,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // NAME + EMAIL
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(
                          right: 35,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              auth.name,
                              style:
                                  const TextStyle(
                                fontSize: 21,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              auth.email,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(
                                      0.6,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // =================================================
                // EDIT PENCIL
                // =================================================

                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    tooltip:
                        'Edit Profile',
                    onPressed: () =>
                        _showEditProfile(
                      context,
                    ),
                    icon: const Icon(
                      Icons.edit_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ======================================================
          // APP SETTINGS
          // ======================================================

          _item(
            context,
            icon: Icons.settings_outlined,
            title: 'App Settings',
            subtitle:
                'Theme and app preferences',
            onTap: () {
              _showInfo(
                context,
                'The project currently uses a premium dark Material 3 theme.',
              );
            },
          ),

          // ======================================================
          // ABOUT
          // ======================================================

          _item(
            context,
            icon:
                Icons.info_outline_rounded,
            title: 'About',
            subtitle:
                AppConfig.appName,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName:
                    AppConfig.appName,
                applicationVersion:
                    '1.0.0',
                applicationIcon:
                    const Icon(
                  Icons.movie_filter_rounded,
                ),
                children: const [
                  Text(
                    'A university project for discovering movies and TV series using public metadata APIs.',
                  ),
                ],
              );
            },
          ),

          // ======================================================
          // PRIVACY POLICY
          // ======================================================

          _item(
            context,
            icon:
                Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle:
                'Learn how your information is handled',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          // ======================================================
          // LOGOUT BUTTON
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _logout(context),
              icon: const Icon(
                Icons.logout_rounded,
              ),
              label: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ======================================================
          // DELETE ACCOUNT BUTTON
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _deleteAccount(context),
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
              label: const Text(
                'Delete Account',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE ITEM
  // ============================================================

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(
                  alpha: 0.12,
                ),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // INFO BOTTOM SHEET
  // ============================================================

  void _showInfo(
    BuildContext context,
    String message,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding:
            const EdgeInsets.fromLTRB(
          24,
          8,
          24,
          30,
        ),
        child: Text(
          message,
          style: const TextStyle(
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PRIVACY POLICY SCREEN
// ================================================================

class PrivacyPolicyScreen
    extends StatelessWidget {
  const PrivacyPolicyScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        children: const [
          Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 26,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Last updated: August 20, 2026',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 24),

          Text(
            '1. Information We Collect',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'The application may collect information required to provide account functionality, such as your name and email address. If you choose to add a profile image, the application may store that image locally on your device.',
            style: TextStyle(
              height: 1.6,
            ),
          ),

          SizedBox(height: 22),

          Text(
            '2. How We Use Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Your information is used to provide authentication, maintain your profile, and provide the features available within the application.',
            style: TextStyle(
              height: 1.6,
            ),
          ),

          SizedBox(height: 22),

          Text(
            '3. Movie and TV Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Movie and TV metadata displayed in the application may be provided by third-party public APIs. The application does not claim ownership of third-party movie metadata, posters, or related content.',
            style: TextStyle(
              height: 1.6,
            ),
          ),

          SizedBox(height: 22),

          Text(
            '4. Data Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'We take reasonable steps to protect information used by the application. However, no electronic storage or transmission method can be guaranteed to be completely secure.',
            style: TextStyle(
              height: 1.6,
            ),
          ),

          SizedBox(height: 22),

          Text(
            '5. Your Choices',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'You can update your profile information and remove your profile image from the Profile section of the application.',
            style: TextStyle(
              height: 1.6,
            ),
          ),

          SizedBox(height: 22),

          Text(
            '6. Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'If you have questions about this Privacy Policy or the application, please contact the application developer.',
            style: TextStyle(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}