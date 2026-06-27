import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../theme/app_theme.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: '');
  final _passwordCtrl = TextEditingController(text: '');
  bool _showPassword = false;
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<ap.AuthProvider>();
    bool success;
    if (_isRegisterMode) {
      success = await auth.registerWithEmail(
          _emailCtrl.text, _passwordCtrl.text);
    } else {
      success = await auth.signInWithEmail(
          _emailCtrl.text, _passwordCtrl.text);
    }
    if (success && mounted) _navigateToMain();
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<ap.AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) _navigateToMain();
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your email first.'),
      ));
      return;
    }
    try {
      await context.read<ap.AuthProvider>().sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          backgroundColor: Color(0xFF22C55E),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to send reset email.'),
          backgroundColor: Color(0xFFEF4444),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Brand header
              Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text('M',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('MediScan AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.darkBlue,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    'Clinical Intelligence Portal',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Login card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRegisterMode ? 'Create Account' : 'Welcome Back',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Secure access to your medical analysis',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 20),

                    if (auth.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFECACA)),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          _buildLabel('Email Address'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'name@example.com',
                              prefixIcon: Icon(Icons.email_outlined,
                                  size: 18,
                                  color: Colors.grey.shade400),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppTheme.primaryBlue, width: 2),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Email is required';
                              }
                              if (!v.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('Password'),
                              if (!_isRegisterMode)
                                TextButton(
                                  onPressed: _forgotPassword,
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: Icon(Icons.lock_outline,
                                  size: 18,
                                  color: Colors.grey.shade400),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppTheme.primaryBlue, width: 2),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Sign In / Register button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  auth.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 3,
                                shadowColor: AppTheme.primaryBlue
                                    .withOpacity(0.3),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : Text(
                                      _isRegisterMode
                                          ? 'Create Account →'
                                          : 'Sign In →',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Color(0xFFF3F4F6))),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade400,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFFF3F4F6))),
                        ],
                      ),
                    ),

                    // Google button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed:
                            auth.isLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _googleIcon(),
                            const SizedBox(width: 10),
                            const Text('Google',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _isRegisterMode = !_isRegisterMode),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            children: [
                              TextSpan(
                                text: _isRegisterMode
                                    ? 'Already have an account? '
                                    : 'New to MediScan AI? ',
                              ),
                              TextSpan(
                                text: _isRegisterMode
                                    ? 'Sign In'
                                    : 'Create an account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // HIPAA footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 14, color: AppTheme.green),
                  const SizedBox(width: 6),
                  Text(
                    'HIPAA Compliant  •  256-bit Encryption',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _googleIcon() {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  const _GoogleIconPainter();
  @override
  void paint(Canvas canvas, Size size) {
    // Simplified Google 'G' as colored circle
    final circlePaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / 2, circlePaint);
    final textPaint = Paint()..color = Colors.white;
    // Simple white circle inside
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / 3, textPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
