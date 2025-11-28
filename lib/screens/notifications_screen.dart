import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final notifications = await ApiService.fetchNotifications();
      
      // 🔍 Debug: Log all notification types received from backend
      print('📋 Total notifications received: ${notifications.length}');
      for (var notif in notifications) {
        print('📌 Notification: type="${notif['type']}", title="${notif['title']}"');
      }
      
      // Count by type for debugging
      final typeCounts = <String, int>{};
      for (var notif in notifications) {
        final type = notif['type']?.toString() ?? 'unknown';
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }
      print('📊 Notification types breakdown: $typeCounts');
      
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'badge':
        return Icons.emoji_events;
      case 'milestone':
        return Icons.star;
      case 'motivation':
        return Icons.auto_awesome;
      case 'system':
        return Icons.info;
      case 'update':
        return Icons.new_releases;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'badge':
        return Colors.amber;
      case 'milestone':
        return Colors.green;
      case 'motivation':
        return Colors.pink;
      case 'system':
        return Colors.blue;
      case 'update':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

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
    final unreadCount = _notifications.where((n) => n['isRead'] != true).length;

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
                    onPressed: () async {
                      for (var notification in _notifications) {
                        if (notification['isRead'] != true && notification['_id'] != null) {
                          await ApiService.markNotificationAsRead(notification['_id']);
                        }
                      }
                      
                      setState(() {
                        for (var notification in _notifications) {
                          notification['isRead'] = true;
                        }
                      });
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'All notifications marked as read',
                              style: GoogleFonts.poppins(),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
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
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            final type = notification['type'] ?? 'system';
                            final isRead = notification['isRead'] == true;
                            final createdAt = notification['createdAt'];
                            final time = createdAt != null 
                                ? DateTime.parse(createdAt)
                                : DateTime.now();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isRead ? Colors.grey[100] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isRead
                                      ? Colors.grey[300]!
                                      : _getColorForType(type).withOpacity(0.5),
                                  width: isRead ? 1 : 2,
                                ),
                                boxShadow: isRead ? null : [
                                  BoxShadow(
                                    color: _getColorForType(type).withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: _getColorForType(type),
                                        width: 4,
                                      ),
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
                                    color: _getColorForType(type).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getIconForType(type),
                                    color: _getColorForType(type),
                                    size: 24,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification['title'] ?? 'Notification',
                                        style: GoogleFonts.poppins(
                                          fontWeight: isRead
                                              ? FontWeight.w500
                                              : FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getColorForType(type),
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
                                      notification['message'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatTime(time),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 18,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                onTap: () async {
                                  if (!isRead && notification['_id'] != null) {
                                    await ApiService.markNotificationAsRead(
                                      notification['_id'],
                                    );
                                  }
                                  
                                  setState(() {
                                    notification['isRead'] = true;
                                  });
                                  
                                  // Show notification detail dialog
                                  _showNotificationDetail(notification);
                                },
                              ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'system';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final createdAt = notification['createdAt'];
    final time = createdAt != null ? DateTime.parse(createdAt) : DateTime.now();
    
    // Choose gradient colors based on type
    List<Color> gradientColors;
    switch (type) {
      case 'motivation':
        gradientColors = [Colors.pink.shade300, Colors.purple.shade400];
        break;
      case 'badge':
        gradientColors = [Colors.amber.shade400, Colors.orange.shade500];
        break;
      case 'milestone':
        gradientColors = [Colors.green.shade400, Colors.teal.shade500];
        break;
      default:
        gradientColors = [Colors.blue.shade400, Colors.indigo.shade500];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForType(type),
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Timestamp
                Text(
                  _formatTime(time),
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: gradientColors[0],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      type == 'motivation' ? 'Thank you! 💪' : 'Got it!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
