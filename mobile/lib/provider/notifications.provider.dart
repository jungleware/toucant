import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/services/notification.service.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());
