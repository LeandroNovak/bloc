import 'dart:async';

import 'package:bloc/src/utils/typedefs.dart';

abstract class ListenerMappers {
  static ListenerMapper<T> defaultMapper<T>(
    FutureOr<void> Function(T data) callback,
  ) {
    Stream<T> mapper(event) {
      final controller = StreamController<T>.broadcast(sync: true);

      Future<void> onEvent() async {
        try {
          await callback(event as T);
        } catch (_) {
          rethrow;
        } finally {
          if (!controller.isClosed) {
            await controller.close();
          }
        }
      }

      onEvent();
      return controller.stream;
    }

    return mapper;
  }
}
