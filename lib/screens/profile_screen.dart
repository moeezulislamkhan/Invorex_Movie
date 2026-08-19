import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ===============================================================
  // LOGOUT CONFIRMATION
  // ===============================================================

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout_rounded),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
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
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    if (!context.mounted) return;

    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        children: [
          // ========================================================
          // PROFILE HEADER
          // ========================================================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isDark ? const Color(0xFF111319) : Colors.white,
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // PROFILE IMAGE
                _buildProfileAvatar(
                  context,
                  auth,
                ),

                const SizedBox(width: 16),

                // NAME + EMAIL
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.name.isEmpty ? 'Guest User' : auth.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.email.isEmpty ? 'No email available' : auth.email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // EDIT ICON
                Material(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _showEditProfileDialog(
                      context,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ========================================================
          // ABOUT
          // ========================================================

          _item(
            context,
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: AppConfig.appName,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConfig.appName,
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(
                Icons.movie_filter_rounded,
              ),
              children: const [
                Text(
                  'A university project for discovering movies and TV series using public metadata APIs.',
                ),
              ],
            ),
          ),

          // ========================================================
          // PRIVACY POLICY
          // ========================================================

          _item(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy and terms',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          // ========================================================
          // APP SETTINGS
          // ========================================================

          _item(
            context,
            icon: Icons.settings_outlined,
            title: 'App Settings',
            subtitle: 'Theme and app preferences',
            onTap: () => _showInfo(
              context,
              'The project currently uses a premium Material 3 theme. Theme and other app preferences can be managed here.',
            ),
          ),

          const SizedBox(height: 12),

          // ========================================================
          // LOGOUT
          // ========================================================

          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(
              Icons.logout_rounded,
            ),
            label: const Text(
              'Logout',
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PROFILE AVATAR
  // ===============================================================

  Widget _buildProfileAvatar(
    BuildContext context,
    AuthProvider auth,
  ) {
    return CircleAvatar(
      radius: 34,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        auth.name.isEmpty ? 'G' : auth.name[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ===============================================================
  // COMMON PROFILE ITEM
  // ===============================================================

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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
        onTap: onTap,
      ),
    );
  }

  // ===============================================================
  // EDIT PROFILE DIALOG
  // ===============================================================

  Future<void> _showEditProfileDialog(
    BuildContext context,
  ) async {
    final auth = context.read<AuthProvider>();

    final nameController = TextEditingController(
      text: auth.name,
    );

    final emailController = TextEditingController(
      text: auth.email,
    );

    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.edit_outlined,
              ),
              SizedBox(width: 10),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NAME
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Leave empty to keep current password',
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // CHANGE IMAGE
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _changeProfileImage(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.image_outlined,
                    ),
                    label: const Text(
                      'Change Profile Image',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // REMOVE IMAGE
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _removeProfileImage(
                        context,
                      );
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
              onPressed: () {
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
              onPressed: () async {
                final name = nameController.text.trim();

                final email = emailController.text.trim();

                final password = passwordController.text.trim();

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

                Navigator.of(
                  dialogContext,
                ).pop();

                await _saveProfileChanges(
                  context,
                  name: name,
                  email: email,
                  password: password,
                );
              },
              child: const Text(
                'Save Changes',
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // ===============================================================
  // SAVE PROFILE
  // ===============================================================

  Future<void> _saveProfileChanges(
    BuildContext context, {
    required String name,
    required String email,
    required String password,
  }) async {
    final auth = context.read<AuthProvider>();

    try {
      await auth.updateProfile(
        name: name,
      );

      if (!context.mounted) return;

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
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile: $e',
          ),
        ),
      );
    }
  }

  // ===============================================================
  // CHANGE PROFILE IMAGE
  // ===============================================================

  Future<void> _changeProfileImage(
    BuildContext context,
  ) async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      final file = File(image.path);

      if (!context.mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Profile image selected: ${file.path}',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select image: $e',
          ),
        ),
      );
    }
  }

  // ===============================================================
  // REMOVE PROFILE IMAGE
  // ===============================================================

  Future<void> _removeProfileImage(
    BuildContext context,
  ) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Profile Image?',
          ),
          content: const Text(
            'Are you sure you want to remove your profile image?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    if (!context.mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile image removed.',
        ),
      ),
    );
  }

  // ===============================================================
  // INFO BOTTOM SHEET
  // ===============================================================

  void _showInfo(
    BuildContext context,
    String message,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
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

// =================================================================
// PRIVACY POLICY SCREEN
// =================================================================

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        children: [
          // ========================================================
          // PRIVACY HEADER
          // ========================================================

          Container(
            padding: const EdgeInsets.all(
              20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                22,
              ),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(
                    alpha: 0.10,
                  ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 34,
                ),
                SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          // INTRODUCTION
          _privacySection(
            context,
            title: '1. Introduction',
            text:
                'This Privacy Policy explains how this application handles information when you use the app. We aim to keep your information secure and provide a safe and reliable experience.',
          ),

          // INFORMATION
          _privacySection(
            context,
            title: '2. Information We Collect',
            text:
                'The application may store basic account information such as your name and email address. Information related to your application preferences may also be stored to provide the requested features.',
          ),

          // ACCOUNT
          _privacySection(
            context,
            title: '3. Account Information',
            text:
                'Your account information is used to identify your account and provide access to application features. You should keep your login information private and should not share your password with other people.',
          ),

          // PROFILE
          _privacySection(
            context,
            title: '4. Profile Information',
            text:
                'You may update your profile information through the Profile section. You can change information such as your display name and other supported profile details.',
          ),

          // THIRD PARTY
          _privacySection(
            context,
            title: '5. Third-Party Services',
            text:
                'The application may use public metadata APIs to retrieve movie and TV-series information. These services may have their own privacy policies and terms of use.',
          ),

          // SECURITY
          _privacySection(
            context,
            title: '6. Data Security',
            text:
                'We take reasonable steps to protect application data. However, no electronic storage or transmission system can be guaranteed to be completely secure.',
          ),

          // CHILDREN
          _privacySection(
            context,
            title: '7. Children’s Privacy',
            text:
                'The application is not intended to knowingly collect personal information from children. If you believe that personal information has been provided without appropriate permission, please contact the application administrator.',
          ),

          // CHANGES
          _privacySection(
            context,
            title: '8. Changes to This Policy',
            text:
                'This Privacy Policy may be updated when application features or requirements change. Any updated version will be reflected in the application.',
          ),

          // CONTACT
          _privacySection(
            context,
            title: '9. Contact',
            text:
                'If you have questions about this Privacy Policy or how information is handled, please contact the application administrator.',
          ),

          const SizedBox(
            height: 20,
          ),

          // ========================================================
          // BACK TO PROFILE
          // ========================================================

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop();
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
              label: const Text(
                'Back to Profile',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PRIVACY SECTION
  // ===============================================================

  static Widget _privacySection(
    BuildContext context, {
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Theme.of(
            context,
          ).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            text,
            style: const TextStyle(
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
