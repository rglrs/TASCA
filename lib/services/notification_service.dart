import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final String baseUrl;
  final Future<String> Function() getToken;
  bool _isInitialized = false;

  NotificationService(this.baseUrl, this.getToken);

  Future<void> initializeOneSignal(String oneSignalAppId) async {
    if (_isInitialized) return;
    
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      
      OneSignal.initialize(oneSignalAppId);
      
      OneSignal.Notifications.requestPermission(true);
      
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('OneSignal: Received notification: ${event.notification.title}');
        event.notification.display();
      });
      
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('OneSignal: Notification clicked: ${event.notification.title}');
        if (event.notification.additionalData != null) {
          final taskId = event.notification.additionalData!['task_id'];
          final todoId = event.notification.additionalData!['todo_id'];
          debugPrint('OneSignal: Task ID: $taskId, Todo ID: $todoId');
          
        }
      });

      // Set external user ID jika user sudah login
      _setExternalUserIdIfLoggedIn();
      
      _isInitialized = true;
      debugPrint('OneSignal initialized successfully');
    } catch (e) {
      debugPrint('Error initializing OneSignal: $e');
    }
  }

  Future<void> _setExternalUserIdIfLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final Map<String, dynamic> map = json.decode(decoded);
          
          if (map.containsKey('id')) {
            final userId = map['id'].toString();
            await OneSignal.login(userId);
            debugPrint('Set OneSignal external user ID: $userId');
          }
        }
      }
    } catch (e) {
      debugPrint('Error setting external user ID: $e');
    }
  }

  Future<void> registerDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      debugPrint('NotificationService: No auth token found, skipping device registration');
      return;
    }
    
    try {
      // Dapatkan OneSignal Player ID (device token)
      final deviceState = await OneSignal.User.pushSubscription;
      final playerId = deviceState.id;
      
      if (playerId == null) {
        debugPrint('NotificationService: No OneSignal player ID available');
        return;
      }
      
      debugPrint('NotificationService: Registering device with player ID: $playerId');
      
      // Daftarkan di backend
      final response = await http.post(
        Uri.parse('$baseUrl/api/devices/register'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': playerId,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('NotificationService: Device registered successfully');
      } else {
        debugPrint('NotificationService: Failed to register device: ${response.body}');
      }
    } catch (e) {
      debugPrint('NotificationService: Error registering device: $e');
    }
  }

  Future<void> unregisterDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      debugPrint('NotificationService: No auth token found, skipping device unregistration');
      return;
    }
    
    try {
      // Dapatkan OneSignal Player ID
      final deviceState = await OneSignal.User.pushSubscription;
      final playerId = deviceState.id;
      
      if (playerId == null) {
        debugPrint('NotificationService: No OneSignal player ID available');
        return;
      }
      
      debugPrint('NotificationService: Unregistering device with player ID: $playerId');
      
      // Hapus dari backend
      final response = await http.post(
        Uri.parse('$baseUrl/api/devices/unregister'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': playerId,
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('NotificationService: Device unregistered successfully');
        
        await OneSignal.logout();
        
      } else {
        debugPrint('NotificationService: Failed to unregister device: ${response.body}');
      }
    } catch (e) {
      debugPrint('NotificationService: Error unregistering device: $e');
    }
  }
}