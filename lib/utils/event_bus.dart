// ignore: depend_on_referenced_packages
import 'package:event_bus/event_bus.dart';

final eventBus = EventBus();

// 定义事件
class BlogCreatedEvent {
  BlogCreatedEvent();
}
