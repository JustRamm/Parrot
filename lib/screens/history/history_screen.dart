import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, dynamic>> _historyItems = [
    {
      "date": "Today",
      "items": [
        {"text": "Hello! How are you doing today?", "time": "10:23 AM", "isFavorite": true},
        {"text": "I would like to order a coffee with oat milk.", "time": "09:15 AM", "isFavorite": false},
        {"text": "Where is the nearest restroom?", "time": "08:45 AM", "isFavorite": false},
      ]
    },
    {
      "date": "Yesterday",
      "items": [
        {"text": "Can you help me find the train station?", "time": "14:30 PM", "isFavorite": true},
        {"text": "Nice to meet you.", "time": "11:00 AM", "isFavorite": false},
      ]
    },
    {
      "date": "Jan 15, 2026",
      "items": [
        {"text": "I have a nut allergy.", "time": "19:20 PM", "isFavorite": true},
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Translation History", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppTheme.logoRose),
            onPressed: _showClearHistoryDialog,
            tooltip: "Clear All",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _historyItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _historyItems.length,
              itemBuilder: (context, index) {
                final section = _historyItems[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        (section['date'] as String).toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    ...((section['items'] as List).map((item) => _buildHistoryItem(item, index)).toList()),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, int sectionIndex) {
    return Dismissible(
      key: Key(item['text'] + item['time']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.logoRose.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(LucideIcons.trash2, color: AppTheme.logoRose),
      ),
      onDismissed: (direction) {
        // Handle deletion logic here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item removed from history")),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item['text'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryDark,
                      height: 1.4,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Toggle favorite logic
                    setState(() {
                      item['isFavorite'] = !item['isFavorite'];
                    });
                  },
                  child: Icon(
                    LucideIcons.star,
                    size: 18,
                    color: item['isFavorite'] ? Colors.amber : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.clock, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  item['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Text copied to clipboard")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.logoSage.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.copy, size: 12, color: AppTheme.logoSage),
                        SizedBox(width: 4),
                        Text("Copy", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.logoSage)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.history, size: 48, color: AppTheme.primaryDark.withOpacity(0.3)),
          ),
          const SizedBox(height: 16),
          Text(
            "No History Yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryDark.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History"),
        content: const Text("Are you sure you want to delete all translation history? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _historyItems.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("History cleared")),
              );
            },
            child: const Text("Clear All", style: TextStyle(color: AppTheme.logoRose, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
