import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDummyNotifications();
  }

  Future<void> _loadDummyNotifications() async {
    // Simulate network delay with shimmer effect
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    
    setState(() {
      _notifications = [
        {
          'id': '1',
          'title': 'New Locations ',
          'message': 'We have add new locations around beachside check it out',
          'type': 'message',
          'isRead': false,
          'timestamp': now.subtract(const Duration(minutes: 5)),
        },
        {
          'id': '2',
          'title': 'Security Alert',
          'message': 'Your Located area Tempature get maximus plz drink warter',
          'type': 'alert',
          'isRead': true,
          'timestamp': now.subtract(const Duration(days: 1)),
        },
  
      ];
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final isUnread = notification['isRead'] == false;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  _notifications.insert(index, notification);
                });
              },
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isUnread 
              ? colorScheme.primary.withOpacity(0.05)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getNotificationColor(notification['type'])
                  .withOpacity(isUnread ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification['type']),
              size: 20,
              color: _getNotificationColor(notification['type']),
            ),
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              notification['message'],
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTimestamp(notification['timestamp']),
                style: TextStyle(
                  fontSize: 11,
                  color: isUnread 
                      ? colorScheme.primary 
                      : colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isUnread)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          onTap: () {
            if (isUnread) {
              _markAsRead(notification['id']);
            }
          },
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case 'message':
        return colorScheme.primary;
      case 'event':
        return Colors.blueAccent;
      case 'alert':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      case 'social':
        return Colors.green;
      default:
        return colorScheme.primary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'message':
        return Icons.message_rounded;
      case 'event':
        return Icons.calendar_today_rounded;
      case 'alert':
        return Icons.warning_rounded;
      case 'system':
        return Icons.system_update_rounded;
      case 'social':
        return Icons.people_alt_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
      iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
       
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoader()
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_rounded,
                        size: 48,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDummyNotifications,
                  color: colorScheme.primary,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(_notifications[index], index);
                    },
                  ),
                ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 12,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}