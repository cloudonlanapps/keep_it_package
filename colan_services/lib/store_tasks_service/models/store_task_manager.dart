import 'store_task.dart';

abstract class StoreTaskManager {
  bool add(StoreTask task);
  StoreTask? pop();
}
