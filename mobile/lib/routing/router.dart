import 'package:auto_route/auto_route.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toucant/routing/duplicate_guard.dart';
import 'package:toucant/routing/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  final _duplicateGuard = DuplicateGuard();

  @override
  List<AutoRouteGuard> get guards => [_duplicateGuard];

  @override
  List<AutoRoute> get routes {
    return [
      AutoRoute(page: HomeRoute.page, initial: true),
    ];
  }
}

final appRouterProvider = Provider((ref) => AppRouter());
