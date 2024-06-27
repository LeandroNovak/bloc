import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

/// {@template bloc_generic_builder2}
/// A widget that subscribes to the state changes of the given [bloc] and
/// rebuilds itself when the state changes to [T1] or [T2].
///
/// [builder1] is called every time the state changes to [T1],
///
/// [builder2] is called every time the state changes to [T2],
///
/// When the state is different from [T1] or [T2], an
/// [UnknownBlocStateTypeException] is thrown.
///
/// {@endtemplate}
class BlocGenericBuilder2<T1, T2> extends StatelessWidget {
  /// {@macro bloc_generic_builder2}
  BlocGenericBuilder2({
    required this.bloc,
    required this.builder1,
    required this.builder2,
    super.key,
  })  : assert(T1 != dynamic),
        assert(T2 != dynamic);

  /// The [Bloc] that this widget subscribes to.
  final Bloc<Object, Object> bloc;

  /// A function that builds the widget when the state is [T1].
  final Widget Function(BuildContext context, T1 state) builder1;

  /// A function that builds the widget when the state is [T2].
  final Widget Function(BuildContext context, T2 state) builder2;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state, child) {
        if (state is T1) {
          return builder1(context, state as T1);
        }
        if (state is T2) {
          return builder2(context, state as T2);
        }
        throw UnknownBlocStateTypeException();
      },
    );
  }
}
