import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class AppUtils {
  // Date formatters
  static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _monthYearFormatter = DateFormat('MMM yyyy');
  static final DateFormat _timeFormatter = DateFormat('hh:mm a');
  static final DateFormat _fullDateTimeFormatter = DateFormat('MMM dd, yyyy hh:mm a');

  // Currency formatter
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  static final NumberFormat _percentFormatter = NumberFormat.percentPattern();

  // Date formatting
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  static String formatFullDateTime(DateTime date) {
    return _fullDateTimeFormatter.format(date);
  }

  // Currency formatting
  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatPercentage(double value) {
    return _percentFormatter.format(value);
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.length >= 2;
  }

  static bool isValidSalary(String salary) {
    final amount = double.tryParse(salary);
    return amount != null && amount > 0;
  }

  // String helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return '';
  }

  // Responsive helpers
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint && 
           width < AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;
  }

  // Get responsive padding
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return AppConstants.paddingMedium;
    } else if (isTablet(context)) {
      return AppConstants.paddingLarge;
    } else {
      return AppConstants.paddingXLarge;
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  // Snackbar helpers
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  // Dialog helpers
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Loading overlay
  static void showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppConstants.paddingMedium),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hideLoadingOverlay(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Generate employee ID
  static String generateEmployeeId() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final random = (DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'EMP$year$month$random';
  }

  // Calculate age from date of birth
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Get current financial year
  static String getCurrentFinancialYear() {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final endYear = startYear + 1;
    return '$startYear-${endYear.toString().substring(2)}';
  }

  // Get month name
  static String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Generate random color for avatars
  static Color getRandomColor(String seed) {
    final colors = AppColors.chartColors;
    final index = seed.hashCode % colors.length;
    return colors[index.abs()];
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Debounce function for search
  static void debounce(Duration delay, VoidCallback callback) {
    Timer? timer;
    timer?.cancel();
    timer = Timer(delay, callback);
  }
}

// Custom page transitions
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlideRightRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: AppConstants.pageTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

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

class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadeRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: AppConstants.pageTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}