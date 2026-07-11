import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../data/models/opportunity.dart';
import '../../../core/theme/app_colors.dart';

class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() => _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _hoursController = TextEditingController();
  final _skillsController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCategory = 'Design';
  String _selectedLocation = 'Remote';
  bool _isLoading = false;

  final List<String> _categories = ['Design', 'Engineering', 'Marketing', 'Data', 'Other'];
  final List<String> _locations = ['Remote', 'On-campus', 'Kigali', 'Hybrid'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _hoursController.dispose();
    _skillsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final oppProvider = Provider.of<OpportunityProvider>(context, listen: false);
    
    final user = authProvider.userProfile;
    final startupName = user?.startupName ?? 'ALU Startup';

    // Parse comma separated fields
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
        
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Default tag addition if user misses it
    if (tags.isEmpty) {
      tags.add(_selectedCategory);
      tags.add(_selectedLocation);
    }

    try {
      final opp = Opportunity(
        id: '', // Will be set by repository
        title: _titleController.text.trim(),
        company: startupName,
        location: _selectedLocation,
        hoursPerWeek: _hoursController.text.trim(),
        postedDate: DateTime.now(),
        category: _selectedCategory,
        description: _descController.text.trim(),
        skills: skills,
        tags: tags,
        postedBy: user?.id ?? '',
      );

      await oppProvider.createOpportunity(opp);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opportunity posted successfully!'),
          backgroundColor: AppColors.shortlistedBadge,
        ),
      );

      // Reset form
      _titleController.clear();
      _descController.clear();
      _hoursController.clear();
      _skillsController.clear();
      _tagsController.clear();
      setState(() {
        _selectedCategory = 'Design';
        _selectedLocation = 'Remote';
        _isLoading = false;
      });

      // Navigate back to the dashboard tab
      Provider.of<TabNavigationProvider>(context, listen: false).setTab(0);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post role: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            'Post Opportunity',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create a new internship role for ALU students.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  
                  // Role Title
                  Text('Opportunity Title', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. UX Research Volunteer',
                      prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Category & Location dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: _categories.map((c) {
                                return DropdownMenuItem(value: c, child: Text(c));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val ?? 'Design'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedLocation,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: _locations.map((l) {
                                return DropdownMenuItem(value: l, child: Text(l));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedLocation = val ?? 'Remote'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Hours per week
                  Text('Expected Hours / Duration', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _hoursController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 4-6 hrs/week or Part-time',
                      prefixIcon: Icon(Icons.access_time_rounded, color: AppColors.textSecondary),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Hours/duration is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Required Skills
                  Text('Skills Required (Comma separated)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _skillsController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Flutter, Dart, Problem Solving',
                      prefixIcon: Icon(Icons.bolt_outlined, color: AppColors.textSecondary),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Skills are required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Custom tags
                  Text('Tags (Comma separated - Optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. UX Design, Research, Remote',
                      prefixIcon: Icon(Icons.local_offer_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text('Detailed Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Describe the venture objectives, expected contributions, and benefits...',
                      prefixIcon: Icon(Icons.description_outlined, color: AppColors.textSecondary),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Post Opportunity',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
