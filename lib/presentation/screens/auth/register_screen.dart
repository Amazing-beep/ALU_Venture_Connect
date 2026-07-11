import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _startupNameController = TextEditingController();
  final _regNumController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _startupNameController.dispose();
    _regNumController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Parse skills
    List<String> skillsList = [];
    if (_selectedRole == UserRole.student && _skillsController.text.isNotEmpty) {
      skillsList = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    try {
      await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        startupName: _selectedRole == UserRole.startup ? _startupNameController.text.trim() : null,
        registrationNumber: _selectedRole == UserRole.startup ? _regNumController.text.trim() : null,
        bio: _selectedRole == UserRole.student ? _bioController.text.trim() : _bioController.text.trim(),
        skills: _selectedRole == UserRole.student ? skillsList : null,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/email_verification',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 30,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the ALU VentureConnect community.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Role Selector (Premium pill button design)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = UserRole.student),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == UserRole.student
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedRole == UserRole.student
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'ALU Student',
                              style: TextStyle(
                                color: _selectedRole == UserRole.student
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = UserRole.startup),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == UserRole.startup
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedRole == UserRole.startup
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Startup Founder',
                              style: TextStyle(
                                color: _selectedRole == UserRole.startup
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Full Name
                  Text(
                    _selectedRole == UserRole.student ? 'Full Name' : 'Founder Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: _selectedRole == UserRole.student
                          ? 'e.g. Amazing Mkhonta'
                          : 'e.g. Founder Name',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Startup Name (Conditional)
                  if (_selectedRole == UserRole.startup) ...[
                    Text(
                      'Startup Venture Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _startupNameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Learnify',
                        prefixIcon: Icon(Icons.business_outlined, color: AppColors.textSecondary),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Startup name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ALU Venture Registration ID
                    Text(
                      'ALU Venture ID (For Validation)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _regNumController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. ALU-V-2026-XXX',
                        prefixIcon: Icon(Icons.verified_user_outlined, color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'ALU Venture ID is required for verification';
                        }
                        if (!value.trim().toUpperCase().startsWith('ALU-V-')) {
                          return 'ID must start with ALU-V- (e.g. ALU-V-2026-102)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  Text(
                    'Email Address',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'e.g. amina@alu.edu',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Text(
                    'Password',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Minimum 6 characters',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Student Skills (Conditional)
                  if (_selectedRole == UserRole.student) ...[
                    Text(
                      'Skills & Interests (Comma separated)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Flutter, Dart, UX Design, Python',
                        prefixIcon: Icon(Icons.bolt_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Bio / Startup Description
                  Text(
                    _selectedRole == UserRole.student ? 'Short Bio' : 'Startup Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _selectedRole == UserRole.student
                          ? 'Describe your academic background and interests...'
                          : 'Describe your startup project and goals...',
                      prefixIcon: const Icon(Icons.description_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Link to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
