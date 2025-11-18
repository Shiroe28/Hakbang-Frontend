import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Welcome to Hakbang!',
      'message':
          'Start your IT career journey today. Complete your profile and take the career assessment quiz.',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'icon': Icons.celebration,
      'color': Colors.purple,
      'isRead': false,
    },
    {
      'title': 'New Learning Module Available',
      'message':
          'Check out "Introduction to Web Development" in the Web Developer career path.',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'icon': Icons.school,
      'color': Colors.blue,
      'isRead': false,
    },
    {
      'title': 'Take the Career Quiz',
      'message':
          'Not sure which IT career is right for you? Take our AI-powered career assessment quiz!',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.quiz,
      'color': Colors.orange,
      'isRead': true,
    },
    {
      'title': 'Community Activity',
      'message': 'Someone replied to your post in the community forum.',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.forum,
      'color': Colors.green,
      'isRead': true,
    },
  ];

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2c6894), // Azure blue
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (unreadCount > 0)
                        Text(
                          '$unreadCount unread',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var notification in _notifications) {
                          notification['isRead'] = true;
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'All notifications marked as read',
                            style: GoogleFonts.poppins(),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      'Mark all read',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: notification['isRead']
                              ? Colors.grey[100]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: notification['isRead']
                                ? Colors.grey[300]!
                                : const Color(0xFF2c6894).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2c6894).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              notification['icon'],
                              color: const Color(0xFF2c6894),
                              size: 24,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: notification['isRead']
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (!notification['isRead'])
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2c6894),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                notification['message'],
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTime(notification['time']),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            setState(() {
                              notification['isRead'] = true;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
