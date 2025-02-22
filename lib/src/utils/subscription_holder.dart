import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// A class that manages the subscriptions and provides a
/// composite subscription that can be used to dispose all the subscriptions
/// at once.
abstract class SubscriptionHolder {
  /// A [CompositeSubscription] that can be used to dispose all the
  /// subscriptions at once.
  @protected
  final subscriptions = CompositeSubscription();

  /// Closes all the subscriptions.
  @protected
  @mustCallSuper
  void closeSubscriptions() {
    subscriptions.dispose();
  }
}
