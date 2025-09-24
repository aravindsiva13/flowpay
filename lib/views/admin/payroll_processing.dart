import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../widgets/custom_widgets.dart';
import '../../providers/employee_provider.dart';
import '../../providers/payroll_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/payroll_model.dart';

class PayrollProcessing extends ConsumerStatefulWidget {
  const PayrollProcessing({Key? key}) : super(key: key);

  @override
  ConsumerState<PayrollProcessing> createState() => _PayrollProcessingState();
}

class _PayrollProcessingState extends ConsumerState<PayrollProcessing> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeProvider.notifier).loadEmployees();
      ref.read(payrollProvider.notifier).loadPayrolls();
      ref.read(payrollProvider.notifier).setSelectedPeriod(selectedMonth, selectedYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    final payrollState = ref.watch(payrollProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll Processing'),
        actions: [
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: payrollState.isProcessing,
        loadingText: 'Processing payroll...',
        child: Column(
          children: [
            // Month/Year selector
            _buildPeriodSelector(),
            
            // Summary cards
            _buildSummaryCards(employeeState.employees, payrollState.filteredPayrolls),
            
            // Actions section
            _buildActionButtons(employeeState.employees, payrollState.filteredPayrolls),
            
            // Payroll list
            Expanded(
              child: _buildPayrollList(payrollState.filteredPayrolls),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          const Text(
            'Payroll Period:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Row(
              children: [
                // Month selector
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(AppUtils.getMonthName(month)),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedMonth = value);
                        ref.read(payrollProvider.notifier).setSelectedPeriod(selectedMonth, selectedYear);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                // Year selector
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedYear = value);
                        ref.read(payrollProvider.notifier).setSelectedPeriod(selectedMonth, selectedYear);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<EmployeeModel> employees, List<PayrollModel> payrolls) {
    final totalEmployees = employees.length;
    final processedPayrolls = payrolls.where((p) => p.status == PayrollStatus.approved).length;
    final pendingPayrolls = payrolls.where((p) => p.status == PayrollStatus.pending).length;
    final totalExpense = payrolls.fold<double>(0.0, (sum, p) => sum + p.netSalary);

    final stats = [
      {
        'title': 'Total Employees',
        'value': totalEmployees.toString(),
        'icon': Icons.people,
        'color': AppColors.primaryBlue,
      },
      {
        'title': 'Processed',
        'value': processedPayrolls.toString(),
        'icon': Icons.check_circle,
        'color': AppColors.accentGreen,
      },
      {
        'title': 'Pending',
        'value': pendingPayrolls.toString(),
        'icon': Icons.pending,
        'color': AppColors.warningOrange,
      },
      {
        'title': 'Total Expense',
        'value': AppUtils.formatCurrency(totalExpense),
        'icon': Icons.account_balance_wallet,
        'color': AppColors.chartColors[3],
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppUtils.isMobile(context) ? 2 : 4,
          crossAxisSpacing: AppConstants.paddingSmall,
          mainAxisSpacing: AppConstants.paddingSmall,
          childAspectRatio: 1.5,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return StatsCard(
            title: stat['title'] as String,
            value: stat['value'] as String,
            icon: stat['icon'] as IconData,
            iconColor: stat['color'] as Color,
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(List<EmployeeModel> employees, List<PayrollModel> payrolls) {
    final hasEmployees = employees.isNotEmpty;
    final hasUnprocessedPayroll = payrolls.any((p) => p.status == PayrollStatus.pending);
    final allProcessed = payrolls.isNotEmpty && payrolls.every((p) => p.status == PayrollStatus.approved);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              // Generate Payroll button
              Expanded(
                child: CustomButton(
                  text: 'Generate Payroll',
                  icon: Icons.calculate,
                  onPressed: hasEmployees ? () => _generatePayroll(employees) : null,
                ),
              ),
              if (hasUnprocessedPayroll) ...[
                const SizedBox(width: AppConstants.paddingMedium),
                // Approve All button
                Expanded(
                  child: CustomButton(
                    text: 'Approve All',
                    icon: Icons.check_circle,
                    backgroundColor: AppColors.accentGreen,
                    onPressed: () => _approveAllPayrolls(),
                  ),
                ),
              ],
            ],
          ),
          if (allProcessed) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            CustomButton(
              text: 'Generate Payslips',
              icon: Icons.receipt_long,
              backgroundColor: AppColors.chartColors[2],
              onPressed: () => _generatePayslips(employees),
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayrollList(List<PayrollModel> payrolls) {
    if (payrolls.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long,
        title: 'No payroll data',
        subtitle: 'Generate payroll for this period to see employee salary details',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: payrolls.length,
        itemBuilder: (context, index) {
          final payroll = payrolls[index];
          return _buildPayrollCard(payroll);
        },
      ),
    );
  }

  Widget _buildPayrollCard(PayrollModel payroll) {
    return CustomCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              EmployeeAvatar(
                name: payroll.employeeName,
                size: 40,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payroll.employeeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      payroll.employeeId,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(status: payroll.status),
              const SizedBox(width: AppConstants.paddingSmall),
              PopupMenuButton<String>(
                onSelected: (value) => _handlePayrollAction(value, payroll),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('View Details')),
                  if (payroll.status == PayrollStatus.pending)
                    const PopupMenuItem(value: 'approve', child: Text('Approve')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Salary breakdown
          Row(
            children: [
              Expanded(
                child: _buildSalaryItem('Gross', payroll.grossSalary, AppColors.primaryBlue),
              ),
              Expanded(
                child: _buildSalaryItem('Deductions', payroll.totalDeductions, AppColors.errorRed),
              ),
              Expanded(
                child: _buildSalaryItem('Net Pay', payroll.netSalary, AppColors.accentGreen),
              ),
            ],
          ),
          
          if (payroll.notes?.isNotEmpty == true) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.note,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      payroll.notes!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSalaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppUtils.formatCurrency(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _generatePayroll(List<EmployeeModel> employees) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Generate Payroll',
      content: 'Generate payroll for ${AppUtils.getMonthName(selectedMonth)} $selectedYear?\n\nThis will calculate salaries for all ${employees.length} employees.',
      confirmText: 'Generate',
    );

    if (confirmed == true) {
      try {
        await ref.read(payrollProvider.notifier).generatePayrollForMonth(
          employees: employees,
          month: selectedMonth,
          year: selectedYear,
        );
        
        if (mounted) {
          AppUtils.showSuccessSnackbar(
            context,
            'Payroll generated successfully for ${employees.length} employees',
          );
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showErrorSnackbar(context, 'Failed to generate payroll');
        }
      }
    }
  }

  void _approveAllPayrolls() async {
    final payrollState = ref.read(payrollProvider);
    final pendingCount = payrollState.filteredPayrolls
        .where((p) => p.status == PayrollStatus.pending)
        .length;

    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Approve All Payrolls',
      content: 'Approve $pendingCount pending payrolls for ${AppUtils.getMonthName(selectedMonth)} $selectedYear?',
      confirmText: 'Approve All',
    );

    if (confirmed == true) {
      try {
        final currentUser = await ref.read(authProvider.notifier).getCurrentUserModel();
        await ref.read(payrollProvider.notifier).approveAllPayrolls(
          month: selectedMonth,
          year: selectedYear,
          approvedBy: currentUser?.name ?? 'Admin',
        );
        
        if (mounted) {
          AppUtils.showSuccessSnackbar(
            context,
            'All payrolls approved successfully',
          );
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showErrorSnackbar(context, 'Failed to approve payrolls');
        }
      }
    }
  }

  void _generatePayslips(List<EmployeeModel> employees) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Generate Payslips',
      content: 'Generate payslips for all approved payrolls in ${AppUtils.getMonthName(selectedMonth)} $selectedYear?',
      confirmText: 'Generate',
    );

    if (confirmed == true) {
      try {
        await ref.read(payrollProvider.notifier).generatePayslips(
          month: selectedMonth,
          year: selectedYear,
          employees: employees,
        );
        
        if (mounted) {
          AppUtils.showSuccessSnackbar(context, 'Payslips generated successfully');
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showErrorSnackbar(context, 'Failed to generate payslips');
        }
      }
    }
  }

  void _handlePayrollAction(String action, PayrollModel payroll) async {
    switch (action) {
      case 'view':
        _showPayrollDetails(payroll);
        break;
      case 'approve':
        _approvePayroll(payroll);
        break;
      case 'edit':
        _editPayroll(payroll);
        break;
    }
  }

  void _showPayrollDetails(PayrollModel payroll) {
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
                children: [
                  EmployeeAvatar(name: payroll.employeeName, size: 50),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payroll.employeeName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${payroll.employeeId} • ${payroll.payPeriod}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: payroll.status),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: _buildPayrollDetailsContent(payroll),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollDetailsContent(PayrollModel payroll) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPayrollSection('Earnings', [
          _buildPayrollDetailRow('Basic Salary', payroll.basicSalary),
          _buildPayrollDetailRow('HRA', payroll.hra),
          _buildPayrollDetailRow('DA', payroll.da),
          _buildPayrollDetailRow('Other Allowances', payroll.otherAllowances),
          _buildPayrollDetailRow('Gross Salary', payroll.grossSalary, isTotal: true),
        ]),
        
        _buildPayrollSection('Deductions', [
          _buildPayrollDetailRow('PF Deduction', payroll.pfDeduction),
          _buildPayrollDetailRow('ESI Deduction', payroll.esiDeduction),
          _buildPayrollDetailRow('TDS Deduction', payroll.tdsDeduction),
          _buildPayrollDetailRow('Other Deductions', payroll.otherDeductions),
          _buildPayrollDetailRow('Total Deductions', payroll.totalDeductions, isTotal: true),
        ]),
        
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NET PAY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGreen,
                ),
              ),
              Text(
                AppUtils.formatCurrency(payroll.netSalary),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGreen,
                ),
              ),
            ],
          ),
        ),
        
        if (payroll.notes?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              payroll.notes!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPayrollSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPayrollDetailRow(String label, double amount, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            AppUtils.formatCurrency(amount),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _approvePayroll(PayrollModel payroll) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Approve Payroll',
      content: 'Approve payroll for ${payroll.employeeName}?',
      confirmText: 'Approve',
    );

    if (confirmed == true) {
      try {
        final currentUser = await ref.read(authProvider.notifier).getCurrentUserModel();
        await ref.read(payrollProvider.notifier).approvePayroll(
          payroll.id,
          currentUser?.name ?? 'Admin',
        );
        
        if (mounted) {
          AppUtils.showSuccessSnackbar(context, 'Payroll approved successfully');
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showErrorSnackbar(context, 'Failed to approve payroll');
        }
      }
    }
  }

  void _editPayroll(PayrollModel payroll) {
    // For MVP, showing placeholder
    AppUtils.showInfoSnackbar(context, 'Edit payroll feature coming soon');
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(employeeProvider.notifier).refresh(),
      ref.read(payrollProvider.notifier).refresh(),
    ]);
  }
}