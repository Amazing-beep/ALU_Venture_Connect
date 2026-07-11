import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final oppProvider = Provider.of<OpportunityProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    
    final searchController = TextEditingController(text: oppProvider.searchQuery);

    final categories = ['All', 'Design', 'Engineering', 'Marketing', 'Data', 'Other'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            'Explore Opportunities',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (val) => oppProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by title, startup, or skills...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    suffixIcon: oppProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              searchController.clear();
                              oppProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Horizontal categories filter list
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = oppProvider.selectedCategory == cat;
                  
                  return GestureDetector(
                    onTap: () {
                      oppProvider.setCategory(cat);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : const Color(0xFFF1F2F6),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Search results list
            Expanded(
              child: oppProvider.opportunities.isEmpty
                  ? _buildEmptyState(oppProvider.searchQuery)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: oppProvider.opportunities.length,
                      itemBuilder: (context, index) {
                        final opp = oppProvider.opportunities[index];
                        final isBookmarked = bookmarkProvider.isBookmarked(opp.id);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F2F6), width: 1.2),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                opp.company.isNotEmpty ? opp.company[0].toUpperCase() : 'V',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            title: Text(
                              opp.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opp.company,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        opp.hoursPerWeek,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('•', style: TextStyle(color: AppColors.textLight, fontSize: 10)),
                                      const SizedBox(width: 8),
                                      Text(
                                        opp.location,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () => bookmarkProvider.toggleBookmark(opp.id),
                              child: Icon(
                                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/opportunity_details',
                              arguments: opp,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 50, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching opportunities',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            query.isNotEmpty 
                ? 'Try revising search keywords.' 
                : 'No postings are available in this category yet.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
