// ignore_for_file: comment_references

import 'package:bloc/src/utils/typedefs.dart';
import 'package:rxdart/rxdart.dart';

/// A set of functions used by [Bloc] and [ActionBloc] to apply modifiers to the
/// listeners.
///
/// Has some default modifiers like `flatMap`, `switchMap`, `debounce`, etc.
///
/// If you want to create your own modifier, you can use the [ListenerModifier]
/// typedef. For example:
/// ```dart
/// ListenerModifier<T> myModifier<T>() => (events, mapper) =>
///   events.myOperator(mapper);
/// ```
abstract class ListenerModifiers {
  /// The default modifier used by [Bloc] and [ActionBloc]. It's the `flatMap`
  /// modifier.
  static ListenerModifier<T> defaultModifier<T>() => flatMap();

  static ListenerModifier<T> flatMap<T>({int? maxConcurrent}) =>
      (events, mapper) => events.flatMap(mapper, maxConcurrent: maxConcurrent);

  static ListenerModifier<T> switchMap<T>() =>
      (events, mapper) => events.switchMap(mapper);

  static ListenerModifier<T> exhaustMap<T>() =>
      (events, mapper) => events.exhaustMap(mapper);

  static ListenerModifier<T> debounce<T>() =>
      (events, mapper) => events.debounce(mapper);

  static ListenerModifier<T> debounceTime<T>(Duration duration) =>
      (events, mapper) => events.debounceTime(duration).flatMap(mapper);

  static ListenerModifier<T> throttle<T>() =>
      (events, mapper) => events.throttle(mapper);

  static ListenerModifier<T> throttleTime<T>(Duration duration) =>
      (events, mapper) => events.throttleTime(duration).flatMap(mapper);
}
