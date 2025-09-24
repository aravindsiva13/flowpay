import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../core/routes.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/charts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/payroll_provider.dart';
import '../../models/dashboard_model.dart';
import '../../services/mock_data.dart';

class EmployeeDashboard extends ConsumerStatefulWidget {
  const EmployeeDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends ConsumerState<EmployeeDashboard> {
  String? employeeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  void _initializeDashboard() async {
    final currentUser = await ref.read(authProvider.notifier).getCurrentUserModel();
    if (currentUser != null) {
      // In mock mode, get employee data by user ID
      final employee = MockDataService.getEmployeeByUserId(currentUser.id);
      if (employee != null) {
        employeeId = employee.id;
        ref.read(dashboardProvider.notifier).loadEmployeeDashboard(employee.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final notificationsCount = ref.watch(dashboardProvider.notifier).unreadNotificationsCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        elevation: 0,
        actions: [
          // Notifications
          Stack(
            children: [
              IconButton(
                onPressed: () => _showNotifications(context),
                icon: const Icon(Icons.notifications_outlined),
              ),
              if (notificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Profile menu
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshDashboard(),
        child: LoadingOverlay(
          isLoading: dashboardState.isLoading && dashboardState.employeeData == null,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppUtils.getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                _buildWelcomeHeader(),
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Salary overview cards
                _buildSalaryOverview(dashboardState.employeeData),
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Quick actions
                _buildQuickActions(),
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Latest payslip
                _buildLatestPayslip(dashboardState.employeeData),
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Charts section
                if (AppUtils.isDesktop(context))
                  _buildChartsRow(dashboardState.employeeData)
                else
                  _buildChartsColumn(dashboardState.employeeData),
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Recent payslips
                _buildRecentPayslips(dashboardState.employeeData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final currentUser = ref.watch(currentUserProvider);
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : 
                    now.hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return currentUser.when(
      data: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${user?.name ?? 'Employee'}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Here\'s your payroll summary and recent activity.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSalaryOverview(EmployeeDashboardData? data) {
    final stats = [
      {
        'title': 'Current Month Salary',
        'value': AppUtils.formatCurrency(data?.currentMonthSalary ?? 0),
        'icon': Icons.account_balance_wallet,
        'color': AppColors.primaryBlue,
        'subtitle': AppUtils.formatMonthYear(DateTime.now()),
      },
      {
        'title': 'Year to Date',
        'value': AppUtils.formatCurrency(data?.yearToDateSalary ?? 0),
        'icon': Icons.trending_up,
        'color': AppColors.accentGreen,
        'subtitle': '${DateTime.now().year} earnings',
      },
      {
        'title': 'Total Deductions',
        'value': AppUtils.formatCurrency(data?.totalDeductions ?? 0),
        'icon': Icons.remove_circle_outline,
        'color': AppColors.warningOrange,
        'subtitle': 'PF + ESI + TDS',
      },
      {
        'title': 'Net Pay',
        'value': AppUtils.formatCurrency((data?.currentMonthSalary ?? 0) - (data?.totalDeductions ?? 0)),
        'icon': Icons.account_balance,
        'color': AppColors.chartColors[3],
        'subtitle': 'Take home',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppUtils.isMobile(context) ? 2 : 4,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
        childAspectRatio: AppUtils.isMobile(context) ? 1.2 : 1.0,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return StatsCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          icon: stat['icon'] as IconData,
          iconColor: stat['color'] as Color,
          subtitle: stat['subtitle'] as String,
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final quickActions = ref.watch(quickActionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppUtils.isMobile(context) ? 2 : 4,
            crossAxisSpacing: AppConstants.paddingMedium,
            mainAxisSpacing: AppConstants.paddingMedium,
            childAspectRatio: 1.5,
          ),
          itemCount: quickActions.length,
          itemBuilder: (context, index) {
            final action = quickActions[index];
            return _buildQuickActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return CustomCard(
      onTap: action.isEnabled ? () => _handleQuickAction(action) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Text(
                  action.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              if (action.badge != null && action.badge! > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      action.badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            action.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: action.isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            action.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLatestPayslip(EmployeeDashboardData? data) {
    if (data?.latestPayslip == null) {
      return CustomCard(
        child: Column(
          children: [
            const Icon(
              Icons.description_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            const Text(
              'No payslips available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            const Text(
              'Your payslips will appear here once generated.',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final payslip = data!.latestPayslip!;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Payslip',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              CustomButton(
                text: 'View',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.payslipViewer),
                isOutlined: true,
                width: 80,
                height: 36,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payslip.payPeriod,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Net Pay: ${AppUtils.formatCurrency(payslip.netPay)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: const Icon(
                  Icons.file_download,
                  color: AppColors.accentGreen,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(EmployeeDashboardData? data) {
    return Row(
      children: [
        Expanded(child: _buildSalaryBreakdownChart(data)),
        const SizedBox(width: AppConstants.paddingLarge),
        Expanded(child: _buildYearlyEarningsChart(data)),
      ],
    );
  }

  Widget _buildChartsColumn(EmployeeDashboardData? data) {
    return Column(
      children: [
        _buildSalaryBreakdownChart(data),
        const SizedBox(height: AppConstants.paddingLarge),
        _buildYearlyEarningsChart(data),
      ],
    );
  }

  Widget _buildSalaryBreakdownChart(EmployeeDashboardData? data) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salary Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          SizedBox(
            height: 200,
            child: data != null && data.salaryBreakdown.isNotEmpty
                ? SalaryBreakdownChart(data: data.salaryBreakdown)
                : const Center(child: Text('No data available')),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyEarningsChart(EmployeeDashboardData? data) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yearly Earnings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          SizedBox(
            height: 200,
            child: data != null && data.yearlyEarnings.isNotEmpty
                ? MonthlyEarningsChart(data: data.yearlyEarnings)
                : const Center(child: Text('No data available')),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPayslips(EmployeeDashboardData? data) {
    if (data?.recentPayslips.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Payslips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.payslipViewer),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...data!.recentPayslips.take(3).map((payslip) =>
            _buildPayslipItem(payslip)),
        ],
      ),
    );
  }

  Widget _buildPayslipItem(PayslipModel payslip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: InkWell(
        onTap: () => _viewPayslip(payslip),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payslip.payPeriod,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Net Pay: ${AppUtils.formatCurrency(payslip.netPay)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'logout':
        _showLogoutConfirmation();
        break;
      case 'profile':
        // Navigate to profile
        break;
      case 'settings':
        // Navigate to settings
        break;
    }
  }

  void _handleQuickAction(QuickAction action) {
    Navigator.pushNamed(context, action.route);
  }

  void _viewPayslip(PayslipModel payslip) {
    Navigator.pushNamed(context, AppRoutes.payslipViewer);
  }

  void _showNotifications(BuildContext context) {
    final notifications = ref.read(notificationsProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(dashboardProvider.notifier).markAllNotificationsAsRead();
                    },
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isNotEmpty
                  ? ListView.builder(
                      controller: scrollController,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(int.parse('ff${notification.color}', radix: 16)).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(notification.icon, style: const TextStyle(fontSize: 16)),
                          ),
                          title: Text(notification.title),
                          subtitle: Text(notification.message),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                notification.timeAgo,
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            ref.read(dashboardProvider.notifier)
                                .markNotificationAsRead(notification.id);
                          },
                        );
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    if (employeeId != null) {
      await ref.read(dashboardProvider.notifier).refreshEmployeeDashboard(employeeId!);
    }
  }
}