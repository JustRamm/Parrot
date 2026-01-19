import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class GestureLibraryScreen extends StatefulWidget {
  const GestureLibraryScreen({super.key});

  @override
  State<GestureLibraryScreen> createState() => _GestureLibraryScreenState();
}

class _GestureLibraryScreenState extends State<GestureLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  
  final List<String> _categories = ["All", "Common", "Emergency", "Social", "Medical"];

  final List<Map<String, String>> _gestures = [
    {"name": "Hello", "category": "Common", "desc": "Wave your hand from left to right."},
    {"name": "Thank You", "category": "Common", "desc": "Touch your chin with your fingertips and move it forward."},
    {"name": "Emergency", "category": "Emergency", "desc": "Form a fist and tap your chest twice rapidly."},
    {"name": "Help", "category": "Emergency", "desc": "Place one hand flat on the other fist."},
    {"name": "I'm Hungry", "category": "Social", "desc": "Slide your fingers down your chest from throat to stomach."},
    {"name": "Where?", "category": "Social", "desc": "Place palms up and move them in small circles."},
    {"name": "Doctor", "category": "Medical", "desc": "Tap your wrist with two fingers like checking a pulse."},
    {"name": "Medicine", "category": "Medical", "desc": "Rub your palm with your middle finger."},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredGestures = _gestures.where((g) {
      final matchesSearch = g['name']!.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == "All" || g['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Gesture Library", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search gestures...",
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.logoSage.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.logoSage.withOpacity(0.1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Selector
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedCategory = cat),
                        selectedColor: AppTheme.logoSage,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredGestures.length,
              itemBuilder: (context, index) {
                final gesture = filteredGestures[index];
                return _buildGestureCard(gesture);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureCard(Map<String, String> gesture) {
    return InkWell(
      onTap: () => _navigateToDetail(gesture),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.logoSage.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Center(
                  child: Icon(LucideIcons.hand, size: 40, color: AppTheme.logoSage.withOpacity(0.4)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gesture['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.logoSage.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      gesture['category']!.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.logoSage),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Map<String, String> gesture) {
    context.push(
      '/gesture-detail',
      extra: {
        'id': gesture['name']!.toLowerCase(), // Using name as ID for now
        'title': gesture['name']!,
        'category': gesture['category']!,
        'desc': gesture['desc']!,
      },
    );
  }
}
