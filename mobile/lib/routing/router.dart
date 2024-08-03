import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/routing/dupliacte_guard.dart';
import 'package:toucant/routing/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  final _duplicateGuard = DuplicateGuard();

  @override
  List<AutoRoute> get routes {
    return [
      AutoRoute(
        page: SettingsRoute.page,
        guards: [_duplicateGuard],
      ),
    ];
  }
}

final appRouterProvider = Provider((ref) => AppRouter());
