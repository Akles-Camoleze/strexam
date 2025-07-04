import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exam_provider.dart';
import '../../providers/statistics_provider.dart';

class ErrorClearingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _clearErrorsInProviders(route.navigator?.context);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _clearErrorsInProviders(newRoute?.navigator?.context);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _clearErrorsInProviders(previousRoute?.navigator?.context);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _clearErrorsInProviders(previousRoute?.navigator?.context);
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    _clearErrorsInProviders(route.navigator?.context);
  }

  void _clearErrorsInProviders(BuildContext? context) {
    if (context == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();

      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      examProvider.clearError();

      final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      statisticsProvider.clearError();
    } catch (e) {
      print('Error clearing provider errors: $e');
    }
  }
}
