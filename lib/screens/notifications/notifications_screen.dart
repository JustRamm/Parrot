import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Voice Clone Ready",
        "body": "Your 'Formal Public' voice model has been successfully generated and is ready to use.",
        "time": "2 mins ago",
        "icon": LucideIcons.mic,
        "isRead": false,
        "type": "success"
      },
      {
        "title": "New Gestures Added",
        "body": "We've added 15 new ASL gestures to the library. Check them out!",
        "time": "2 hours ago",
        "icon": LucideIcons.bookOpen,
        "isRead": true,
        "type": "info"
      },
      {
        "title": "Security Alert",
        "body": "A new login was detected from a Chrome browser on Windows.",
        "time": "1 day ago",
        "icon": LucideIcons.shieldAlert,
        "isRead": true,
        "type": "warning"
      },
      {
        "title": "Subscription Renewed",
        "body": "Your Pro membership has been renewed for another month.",
        "time": "3 days ago",
        "icon": LucideIcons.creditCard,
        "isRead": true,
        "type": "info"
      },
      {
        "title": "Welcome to Parrot!",
        "body": "Thanks for joining. Start by setting up your voice profile.",
        "time": "1 week ago",
        "icon": LucideIcons.partyPopper,
        "isRead": true,
        "type": "info"
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.checkCheck, color: AppTheme.logoSage),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All marked as read")));
            },
            tooltip: "Mark all as read",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildNotificationItem(notifications[index]);
              },
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
              color: AppTheme.backgroundClean,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bellOff, size: 48, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'];
    final Color iconColor = _getIconColor(notification['type']);
    final Color bgColor = isRead ? Colors.white : AppTheme.logoSage.withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRead ? Colors.grey.shade100 : AppTheme.logoSage.withOpacity(0.2)),
        boxShadow: [
          if (!isRead)
            BoxShadow(
              color: AppTheme.logoSage.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(notification['icon'], size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    Text(
                      notification['time'],
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification['body'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isRead ? Colors.grey.shade600 : AppTheme.primaryDark.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 20),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.logoSage,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'success':
        return AppTheme.logoSage;
      case 'warning':
        return Colors.amber.shade700; // Warning
      case 'error':
        return AppTheme.logoBerry;
      case 'info':
      default:
        return Colors.blue.shade600;
    }
  }
}
