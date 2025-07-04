import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/statistics_provider.dart';

mixin ErrorClearingMixin<T extends StatefulWidget> on State<T> {
  void clearErrorsInProviders(BuildContext context) {
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

  void addTabControllerListener(TabController controller) {
    controller.addListener(() {
      if (!controller.indexIsChanging) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          clearErrorsInProviders(context);
        }
      });
    });
  }
}
