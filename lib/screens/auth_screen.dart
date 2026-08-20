import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool loginMode = true;
  bool obscure = true;
  bool loading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (!loginMode && name.isEmpty) {
    _show('Please enter your name.');
    return;
  }

  if (email.isEmpty || !email.contains('@')) {
    _show('Please enter a valid email.');
    return;
  }

  if (password.length < 4) {
    _show('Password must contain at least 4 characters.');
    return;
  }

  if (!loginMode && password != confirmController.text) {
    _show('Passwords do not match.');
    return;
  }

  setState(() => loading = true);

  try {
    final auth = context.read<AuthProvider>();
    bool success = false;

    if (loginMode) {
      success = await auth.login(
        email: email,
        password: password,
      );

      if (!success) {
        if (mounted) {
          _show('Account not found or invalid email/password.');
        }
        return;
      }
    } else {
      await auth.signUp(
        name: name,
        email: email,
        password: password,
      );

      success = true;
    }

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainShell(),
        ),
        (_) => false,
      );
    }
  } catch (e) {
    if (!mounted) return;

    debugPrint('Authentication Error: $e');

    _show(
      e.toString().replaceFirst('Exception: ', ''),
    );
  } finally {
    if (mounted) {
      setState(() => loading = false);
    }
  }
}

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  Future<void> _showForgotPasswordDialog() async {
    final controller = TextEditingController(
      text: emailController.text.trim(),
    );

    bool sending = false;

    await showDialog(
      context: context,
      barrierDismissible: !sending,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your registered email address. '
                    'We will send you a password reset link.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    enabled: !sending,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@email.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: sending
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: sending
                      ? null
                      : () async {
                          final email =
                              controller.text.trim();

                          if (email.isEmpty ||
                              !email.contains('@')) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid email address.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            sending = true;
                          });

                          try {
                            await context
                                .read<AuthProvider>()
                                .resetPassword(
                                  email: email,
                                );

                            if (!context.mounted) return;

                            Navigator.pop(dialogContext);

                            _show(
                              'Password reset link has been sent to your email.',
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            setDialogState(() {
                              sending = false;
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  e
                                      .toString()
                                      .replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                ),
                              ),
                            );
                          }
                        },
                  child: sending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Send Link'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Image.asset('assets/invorex_logo.png'),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    loginMode ? 'Welcome back' : 'Create your account',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loginMode
                        ? 'Sign in to continue your cinematic journey.'
                        : 'Join Invorex Movies and build your watchlist.',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                        fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  if (!loginMode) ...[
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  if (!loginMode) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: confirmController,
                      obscureText: obscure,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.verified_user_outlined),
                      ),
                    ),
                  ],
                 if (loginMode)
  Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: loading ? null : _showForgotPasswordDialog,
      child: const Text('Forgot Password?'),
    ),
  )
                  else
                    const SizedBox(height: 20),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(loginMode ? 'Login' : 'Create Account'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => loginMode = !loginMode),
                      child: Text(
                        loginMode
                            ? 'New here? Create an account'
                            : 'Already have an account? Login',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
