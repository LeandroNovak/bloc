import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

/// {@template bloc_response_builder}
/// A widget that subscribes to the state changes of the given [bloc] and
/// rebuilds itself when the state changes to [Loading], [Error] or [Success].
///
/// [successBuilder] is called every time the state changes to [Success],
///
/// [loadingBuilder] is called every time the state changes to [Loading],
///
/// [errorBuilder] is called every time the state changes to [Error],
///
/// When the state is different from [Loading], [Error] or [Success], an
/// [UnknownBlocStateTypeException] is thrown.
///
/// {@endtemplate}
class BlocResponseBuilder<Loading, Error, Success> extends StatelessWidget {
  /// {@macro bloc_response_builder}
  BlocResponseBuilder({
    required this.bloc,
    required this.successBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    super.key,
  })  : assert(Loading != dynamic),
        assert(Error != dynamic),
        assert(Success != dynamic);

  /// The [Bloc] that this widget subscribes to.
  final Bloc<Object, Object> bloc;

  /// A function that builds the widget when the state is [Success].
  final Widget Function(BuildContext context, Success success) successBuilder;

  /// A function that builds the widget when the state is [Loading].
  final Widget Function(BuildContext context, Loading loading)? loadingBuilder;

  /// A function that builds the widget when the state is [Error].
  final Widget Function(BuildContext context, Error error)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state, child) {
        if (state is Loading) {
          if (loadingBuilder != null) {
            return loadingBuilder!(context, state as Loading);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is Error) {
          if (errorBuilder != null) {
            return errorBuilder!(context, state as Error);
          }
          return const SizedBox.shrink();
        }

        if (state is Success) {
          return successBuilder(context, state as Success);
        }

        throw UnknownBlocStateTypeException();
      },
    );
  }
}
