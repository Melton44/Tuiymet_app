import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  String _selectedRole = 'Member';
  final List<String> _roles = ['Admin', 'Member'];

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  List<String> _recentEmails = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final bool remember = prefs.getBool('remember_me') ?? false;
    final List<String> savedEmails = prefs.getStringList('saved_emails') ?? [];

    if (mounted) {
      setState(() {
        _rememberMe = remember;
        _recentEmails = savedEmails;
        if (remember && _recentEmails.isNotEmpty) {
          _emailController.clear();
        }
      });
    }
  }

  Future<void> _saveEmailToHistory(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);

    if (_rememberMe) {
      List<String> currentList = prefs.getStringList('saved_emails') ?? [];
      currentList.remove(email);
      currentList.insert(0, email);

      if (currentList.length > 5) {
        currentList = currentList.sublist(0, 5);
      }

      await prefs.setStringList('saved_emails', currentList);
      if (mounted) {
        setState(() {
          _recentEmails = currentList;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // ---------- Firestore user record ----------

  /// Makes sure users/{uid} exists. New accounts are always 'Member'.
  /// Returns the stored role.
  Future<String> _ensureUserRecord(User user) async {
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snap = await ref.get();
      if (snap.exists) {
        return (snap.data()?['role'] as String?) ?? 'Member';
      }
      await ref.set({
        'email': user.email?.toLowerCase(),
        'role': 'Member',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return 'Member';
    } catch (e) {
      // Firestore unreachable: don't block sign-in, fall back to Member.
      debugPrint('Firestore unavailable: $e');
      return 'Member';
    }
  }

  void _goToDashboard(String email, String role) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
        settings: RouteSettings(arguments: {
          'loginType': role,
          'email': email,
        }),
      ),
    );
  }

  /// Shared finish step for email, Google and Apple sign-in.
  /// Rejects people who try to LOG IN without having signed up first.
  Future<void> _completeSignIn(User? user, {required bool isNewUser}) async {
    if (user == null || user.email == null) {
      await FirebaseAuth.instance.signOut();
      if (mounted) setState(() => _isLoading = false);
      _showMessageSnackBar('Could not get an email from this account.', isError: true);
      return;
    }
    final email = user.email!;

    // Social login on a brand-new account while in Log In mode:
    // remove the auto-created account and ask them to sign up.
    if (!_isSignUpMode && isNewUser) {
      try {
        await user.delete();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      if (mounted) setState(() => _isLoading = false);
      _showMessageSnackBar(
        '$email is not registered. Please tap Sign Up to create an account first.',
        isError: true,
      );
      return;
    }

    final storedRole = await _ensureUserRecord(user);

    // Role chosen in the dropdown must match the stored role
    if (!_isSignUpMode && _selectedRole == 'Admin' && storedRole != 'Admin') {
      await FirebaseAuth.instance.signOut();
      if (mounted) setState(() => _isLoading = false);
      _showMessageSnackBar('This account does not have Administrator access.', isError: true);
      return;
    }

    await _saveEmailToHistory(email);
    if (!mounted) return;
    setState(() => _isLoading = false);
    _goToDashboard(email, storedRole);
  }

  // ---------- Email + password ----------

  Future<void> _handleAuthentication() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessageSnackBar('Please fill in all required fields.', isError: true);
      return;
    }
    if (!_isValidEmail(email)) {
      _showMessageSnackBar('Please enter a valid email address.', isError: true);
      return;
    }
    if (_isSignUpMode && password.length < 6) {
      _showMessageSnackBar('Password must be at least 6 characters.', isError: true);
      return;
    }
    if (_isSignUpMode && password != confirmPassword) {
      _showMessageSnackBar('Passwords do not match.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = FirebaseAuth.instance;
      final UserCredential cred = _isSignUpMode
          ? await auth.createUserWithEmailAndPassword(email: email, password: password)
          : await auth.signInWithEmailAndPassword(email: email, password: password);

      await _completeSignIn(cred.user, isNewUser: false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessageSnackBar(_authErrorMessage(e), isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessageSnackBar('Something went wrong: $e', isError: true);
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please Sign In instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password, or this email is not registered. Please Sign Up first.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Authentication failed: ${e.code}';
    }
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      _showMessageSnackBar('Enter your email above first.', isError: true);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessageSnackBar('If this email is registered, a reset link has been sent.');
    } on FirebaseAuthException catch (e) {
      _showMessageSnackBar(_authErrorMessage(e), isError: true);
    }
  }

  // ---------- Google ----------

  Future<void> _handleGoogleSignIn() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      _showMessageSnackBar('Google Sign-In is supported on Android, iOS, and Web.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential? cred;

      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile')
          ..setCustomParameters({'prompt': 'select_account'});
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        final googleAuth = await googleUser?.authentication;
        if (googleAuth == null) {
          if (mounted) setState(() => _isLoading = false);
          return; // user cancelled
        }
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      await _completeSignIn(
        cred.user,
        isNewUser: cred.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (e.code != 'popup-closed-by-user' && e.code != 'cancelled-popup-request') {
        _showMessageSnackBar('Google Sign-In Error: ${e.code}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessageSnackBar('Google Sign-In Error: $e', isError: true);
    }
  }

  // ---------- Apple ----------

  Future<void> _handleAppleSignIn() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      _showMessageSnackBar('Apple Sign-In is supported on iOS, macOS, and Web.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential cred;

      if (kIsWeb) {
        final provider = OAuthProvider('apple.com')
          ..addScope('email')
          ..addScope('name');
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final appleResult = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        );
        final credential = OAuthProvider('apple.com').credential(
          idToken: appleResult.identityToken,
          accessToken: appleResult.authorizationCode,
        );
        cred = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      await _completeSignIn(
        cred.user,
        isNewUser: cred.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (e.code != 'popup-closed-by-user' && e.code != 'cancelled-popup-request') {
        _showMessageSnackBar('Apple Sign-In Error: ${e.code}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessageSnackBar('Apple Sign-In Error: $e', isError: true);
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _selectedRole = 'Member';
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _showMessageSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkGreen = Color(0xFF1B5E20);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sheep.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'assets/logo.jpeg',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                  color: primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.eco, color: Colors.white, size: 30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tuiymet Ecofarmers',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen,
                                ),
                              ),
                              Text(
                                'Ecofarming for Climate-Resilient Future',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            _isSignUpMode ? 'Already have an account? ' : "Don't have an account? ",
                            style: const TextStyle(color: Colors.black87, fontSize: 13),
                          ),
                          OutlinedButton(
                            onPressed: _toggleAuthMode,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Text(
                              _isSignUpMode ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            bool isMobile = constraints.maxWidth < 900;
                            return Flex(
                              direction: isMobile ? Axis.vertical : Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: isMobile ? 0 : 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Better Care.\nGreater Yields.',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w900,
                                          color: darkGreen,
                                          height: 1.1,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'A digital marketplace and veterinary\ncompanion for eco-farmers.',
                                        style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 40, height: 20),
                                Expanded(
                                  flex: isMobile ? 0 : 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.94),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isSignUpMode ? 'Create Account' : 'Welcome Back',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: darkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Select access type to log in to Tuiymet',
                                          style: TextStyle(color: Colors.black54, fontSize: 13),
                                        ),
                                        const SizedBox(height: 16),
                                        DropdownButtonFormField<String>(
                                          key: ValueKey(_isSignUpMode),
                                          initialValue: _selectedRole,
                                          items: _roles.map((role) {
                                            return DropdownMenuItem(
                                              value: role,
                                              child: Text(
                                                role == 'Admin' ? 'System Administrator' : 'Group Member Portal',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) => setState(() => _selectedRole = val!),
                                          decoration: InputDecoration(
                                            labelText: 'Login Access Type',
                                            prefixIcon: const Icon(Icons.admin_panel_settings_outlined, color: primaryGreen),
                                            filled: true,
                                            fillColor: Colors.grey.shade100,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        RawAutocomplete<String>(
                                          textEditingController: _emailController,
                                          focusNode: _emailFocusNode,
                                          optionsBuilder: (TextEditingValue textEditingValue) {
                                            if (_recentEmails.isEmpty) {
                                              return const Iterable<String>.empty();
                                            }
                                            if (textEditingValue.text.isEmpty) {
                                              return _recentEmails;
                                            }
                                            return _recentEmails.where((String option) {
                                              return option
                                                  .toLowerCase()
                                                  .contains(textEditingValue.text.toLowerCase());
                                            });
                                          },
                                          fieldViewBuilder:
                                              (context, controller, focusNode, onEditingComplete) {
                                            return TextField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              keyboardType: TextInputType.emailAddress,
                                              decoration: InputDecoration(
                                                hintText: 'Email address',
                                                prefixIcon:
                                                    const Icon(Icons.email_outlined, color: primaryGreen),
                                                filled: true,
                                                fillColor: Colors.grey.shade100,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            );
                                          },
                                          optionsViewBuilder: (context, onSelected, options) {
                                            return Align(
                                              alignment: Alignment.topLeft,
                                              child: Material(
                                                elevation: 4.0,
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  width: 320,
                                                  constraints: const BoxConstraints(maxHeight: 200),
                                                  color: Colors.white,
                                                  child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    itemCount: options.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      final String option = options.elementAt(index);
                                                      return ListTile(
                                                        leading: const Icon(Icons.history,
                                                            color: primaryGreen, size: 20),
                                                        title: Text(option, style: const TextStyle(fontSize: 13)),
                                                        onTap: () => onSelected(option),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          decoration: InputDecoration(
                                            hintText: 'Password',
                                            prefixIcon:
                                                const Icon(Icons.lock_outline, color: primaryGreen),
                                            suffixIcon: IconButton(
                                              icon: Icon(_obscurePassword
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined),
                                              onPressed: () =>
                                                  setState(() => _obscurePassword = !_obscurePassword),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade100,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        if (_isSignUpMode) ...[
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _confirmPasswordController,
                                            obscureText: _obscureConfirmPassword,
                                            decoration: InputDecoration(
                                              hintText: 'Confirm Password',
                                              prefixIcon: const Icon(Icons.lock_reset_outlined,
                                                  color: primaryGreen),
                                              suffixIcon: IconButton(
                                                icon: Icon(_obscureConfirmPassword
                                                    ? Icons.visibility_off_outlined
                                                    : Icons.visibility_outlined),
                                                onPressed: () => setState(() =>
                                                    _obscureConfirmPassword = !_obscureConfirmPassword),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade100,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        if (!_isSignUpMode)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    value: _rememberMe,
                                                    activeColor: primaryGreen,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        _rememberMe = value ?? false;
                                                      });
                                                    },
                                                  ),
                                                  const Text('Remember me',
                                                      style: TextStyle(fontSize: 13, color: Colors.black87)),
                                                ],
                                              ),
                                              TextButton(
                                                onPressed: _handlePasswordReset,
                                                child: const Text('Forgot password?',
                                                    style: TextStyle(color: primaryGreen, fontSize: 13)),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 44,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryGreen,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: _isLoading ? null : _handleAuthentication,
                                            child: _isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.arrow_forward,
                                                          color: Colors.white, size: 18),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _isSignUpMode ? 'Sign Up' : 'Log In',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: const [
                                            Expanded(child: Divider()),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              child: Text('or',
                                                  style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            ),
                                            Expanded(child: Divider()),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        _SocialAuthButton(
                                          icon: Icons.g_mobiledata,
                                          label: _isSignUpMode
                                              ? 'Sign up with Google'
                                              : 'Continue with Google',
                                          onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                                        ),
                                        const SizedBox(height: 8),
                                        _SocialAuthButton(
                                          icon: Icons.apple,
                                          label: _isSignUpMode ? 'Sign up with Apple' : 'Continue with Apple',
                                          onPressed: _isLoading ? () {} : _handleAppleSignIn,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: const [
                        _FeatureBadge(
                          icon: Icons.storefront_outlined,
                          title: 'Buy & Sell Quality Sheep',
                        ),
                        _FeatureBadge(
                          icon: Icons.medical_services_outlined,
                          title: 'Get Veterinary Recommendations',
                        ),
                        _FeatureBadge(
                          icon: Icons.eco_outlined,
                          title: 'Find Best Feeds & Medicine',
                        ),
                        _FeatureBadge(
                          icon: Icons.people_outline,
                          title: 'Support Local Farmers',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureBadge({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black87),
        label: Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
      ),
    );
  }
}