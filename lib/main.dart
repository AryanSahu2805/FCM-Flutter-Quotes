import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// Background message handler - MUST be top-level function
Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FCM Quotes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Firebase Cloud Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? fcmToken;
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    initializeFirebaseMessaging();
  }

  void initializeFirebaseMessaging() async {
    messaging = FirebaseMessaging.instance;

    // Request permission for iOS (automatically granted on Android)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Subscribe to topic
    messaging.subscribeToTopic("messaging");

    // Get FCM token
    messaging.getToken().then((token) {
      setState(() {
        fcmToken = token;
      });
      print('FCM Token: $token');
      print('\n=================================');
      print('COPY THIS TOKEN FOR TESTING:');
      print(token);
      print('=================================\n');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received");
      print("Notification: ${message.notification?.body}");
      print("Data: ${message.data}");

      // Add to notifications list
      setState(() {
        notifications.insert(
          0,
          NotificationItem(
            title: message.notification?.title ?? 'No Title',
            body: message.notification?.body ?? 'No Body',
            type: message.data['type'] ?? 'regular',
            category: message.data['category'] ?? 'general',
            timestamp: DateTime.now(),
          ),
        );
      });

      // Show dialog based on notification type
      showNotificationDialog(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      showNotificationDialog(message);
    });
  }

  void showNotificationDialog(RemoteMessage message) {
    String type = message.data['type'] ?? 'regular';
    String category = message.data['category'] ?? 'general';

    // Determine theme colors and icon based on type
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String typeLabel;

    switch (type) {
      case 'important':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        icon = Icons.warning_amber_rounded;
        typeLabel = 'URGENT';
        break;
      case 'wisdom':
        backgroundColor = Colors.purple.shade50;
        textColor = Colors.purple.shade900;
        icon = Icons.lightbulb_outline;
        typeLabel = 'WISDOM';
        break;
      case 'motivation':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        icon = Icons.emoji_events;
        typeLabel = 'MOTIVATION';
        break;
      default: // regular
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade900;
        icon = Icons.message;
        typeLabel = 'QUOTE';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(icon, color: textColor, size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      message.notification?.title ?? 'Notification',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.notification?.body ?? 'No message',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              if (category.isNotEmpty) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: textColor,
              ),
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // FCM Token Display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your FCM Token:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: SelectableText(
                    fcmToken ?? 'Loading token...',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Copy this token to send test notifications from Firebase Console',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Waiting for messages...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return NotificationCard(
                        notification: notifications[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Notification Item Model
class NotificationItem {
  final String title;
  final String body;
  final String type;
  final String category;
  final DateTime timestamp;

  NotificationItem({
    required this.title,
    required this.body,
    required this.type,
    required this.category,
    required this.timestamp,
  });
}

// Notification Card Widget
class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    Color borderColor;
    IconData icon;
    String typeLabel;

    switch (notification.type) {
      case 'important':
        cardColor = Colors.red.shade50;
        borderColor = Colors.red;
        icon = Icons.warning_amber_rounded;
        typeLabel = 'URGENT';
        break;
      case 'wisdom':
        cardColor = Colors.purple.shade50;
        borderColor = Colors.purple;
        icon = Icons.lightbulb_outline;
        typeLabel = 'WISDOM';
        break;
      case 'motivation':
        cardColor = Colors.blue.shade50;
        borderColor = Colors.blue;
        icon = Icons.emoji_events;
        typeLabel = 'MOTIVATION';
        break;
      default:
        cardColor = Colors.grey.shade50;
        borderColor = Colors.grey;
        icon = Icons.message;
        typeLabel = 'QUOTE';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: borderColor, size: 24),
                SizedBox(width: 8),
                Text(
                  typeLabel,
                  style: TextStyle(
                    color: borderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                Text(
                  _formatTime(notification.timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              notification.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              notification.body,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (notification.category.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  notification.category.toUpperCase(),
                  style: TextStyle(
                    color: borderColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}