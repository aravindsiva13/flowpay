import 'package:flutter/material.dart';
import '../views/auth/auth_screen.dart';
import '../views/admin/admin_dashboard.dart';
import '../views/employee/employee_dashboard.dart';
import '../views/admin/employee_management.dart';
import '../views/admin/payroll_processing.dart';
import '../views/admin/compliance_reports.dart';
import '../views/employee/payslip_viewer.dart';
import '../views/shared/splash_screen.dart';

class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Dashboard routes
  static const String adminDashboard = '/admin-dashboard';
  static const String employeeDashboard = '/employee-dashboard';
  
  // Admin routes
  static const String employeeManagement = '/employee-management';
  static const String payrollProcessing = '/payroll-processing';
  static const String complianceReports = '/compliance-reports';
  
  // Employee routes
  static const String payslipViewer = '/payslip-viewer';
  static const String profile = '/profile';
  
  // Shared routes
  static const String splash = '/splash';
  static const String settings = '/settings';
  
  // Initial route
  static const String initialRoute = splash;
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings);
      
      case AppRoutes.login:
      case AppRoutes.register:
        return _buildRoute(const AuthScreen(), settings);
      
      case AppRoutes.adminDashboard:
        return _buildRoute(const AdminDashboard(), settings);
      
      case AppRoutes.employeeDashboard:
        return _buildRoute(const EmployeeDashboard(), settings);
      
      case AppRoutes.employeeManagement:
        return _buildRoute(const EmployeeManagement(), settings);
      
      case AppRoutes.payrollProcessing:
        return _buildRoute(const PayrollProcessing(), settings);
      
      case AppRoutes.complianceReports:
        return _buildRoute(const ComplianceReports(), settings);
      
      case AppRoutes.payslipViewer:
        return _buildRoute(const PayslipViewer(), settings);
      
      default:
        return _buildRoute(
          const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRoute _buildRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}

// Route arguments classes
class PayslipViewerArguments {
  final String? employeeId;
  final String? payslipId;
  final int? month;
  final int? year;

  PayslipViewerArguments({
    this.employeeId,
    this.payslipId,
    this.month,
    this.year,
  });
}

class EmployeeManagementArguments {
  final String? employeeId;
  final String? action; // 'add', 'edit', 'view'

  EmployeeManagementArguments({
    this.employeeId,
    this.action,
  });
}

class PayrollProcessingArguments {
  final int? month;
  final int? year;
  final String? employeeId;

  PayrollProcessingArguments({
    this.month,
    this.year,
    this.employeeId,
  });
}

// Navigation helpers
class AppNavigator {
  static void pushReplacementNamed(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(
      context, 
      routeName, 
      arguments: arguments,
    );
  }

  static void pushNamed(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(
      context, 
      routeName, 
      arguments: arguments,
    );
  }

  static void pushAndRemoveUntil(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      routeName, 
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  // Specific navigation methods
  static void toLogin(BuildContext context) {
    pushAndRemoveUntil(context, AppRoutes.login);
  }

  static void toAdminDashboard(BuildContext context) {
    pushAndRemoveUntil(context, AppRoutes.adminDashboard);
  }

  static void toEmployeeDashboard(BuildContext context) {
    pushAndRemoveUntil(context, AppRoutes.employeeDashboard);
  }

  static void toEmployeeManagement(
    BuildContext context, {
    String? employeeId,
    String? action,
  }) {
    pushNamed(
      context,
      AppRoutes.employeeManagement,
      arguments: EmployeeManagementArguments(
        employeeId: employeeId,
        action: action,
      ),
    );
  }

  static void toPayrollProcessing(
    BuildContext context, {
    int? month,
    int? year,
    String? employeeId,
  }) {
    pushNamed(
      context,
      AppRoutes.payrollProcessing,
      arguments: PayrollProcessingArguments(
        month: month,
        year: year,
        employeeId: employeeId,
      ),
    );
  }

  static void toPayslipViewer(
    BuildContext context, {
    String? employeeId,
    String? payslipId,
    int? month,
    int? year,
  }) {
    pushNamed(
      context,
      AppRoutes.payslipViewer,
      arguments: PayslipViewerArguments(
        employeeId: employeeId,
        payslipId: payslipId,
        month: month,
        year: year,
      ),
    );
  }

  static void toComplianceReports(BuildContext context) {
    pushNamed(context, AppRoutes.complianceReports);
  }
}