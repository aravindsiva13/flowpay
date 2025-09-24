import '../models/user_model.dart';
import '../models/payroll_model.dart';
import '../models/dashboard_model.dart';
import '../core/constants.dart';
import '../core/utils.dart';

class MockDataService {
  // Mock users
  static List<UserModel> getMockUsers() {
    return [
      UserModel(
        id: 'admin1',
        email: 'admin@company.com',
        name: 'Admin User',
        role: UserRole.admin,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: 'emp1',
        email: 'john.doe@company.com',
        name: 'John Doe',
        role: UserRole.employee,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: 'emp2',
        email: 'jane.smith@company.com',
        name: 'Jane Smith',
        role: UserRole.employee,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: 'emp3',
        email: 'mike.johnson@company.com',
        name: 'Mike Johnson',
        role: UserRole.employee,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: 'emp4',
        email: 'sarah.wilson@company.com',
        name: 'Sarah Wilson',
        role: UserRole.employee,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Mock employees
  static List<EmployeeModel> getMockEmployees() {
    return [
      EmployeeModel(
        id: 'emp1',
        userId: 'emp1',
        employeeId: 'EMP001',
        name: 'John Doe',
        email: 'john.doe@company.com',
        phone: '+91 9876543210',
        dateOfBirth: DateTime(1990, 5, 15),
        joinDate: DateTime(2023, 1, 15),
        department: Department.engineering,
        designation: 'Senior Software Engineer',
        employmentType: EmploymentType.fullTime,
        basicSalary: 60000,
        hra: 30000,
        da: 9000,
        otherAllowances: 5000,
        grossSalary: 104000,
        address: '123 Tech Street, Bangalore, Karnataka - 560001',
        emergencyContact: '+91 9876543211',
        bankAccountNumber: '1234567890',
        ifscCode: 'HDFC0001234',
        panNumber: 'ABCDE1234F',
        aadhaarNumber: '1234-5678-9012',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      EmployeeModel(
        id: 'emp2',
        userId: 'emp2',
        employeeId: 'EMP002',
        name: 'Jane Smith',
        email: 'jane.smith@company.com',
        phone: '+91 9876543220',
        dateOfBirth: DateTime(1992, 8, 20),
        joinDate: DateTime(2023, 2, 1),
        department: Department.marketing,
        designation: 'Marketing Manager',
        employmentType: EmploymentType.fullTime,
        basicSalary: 55000,
        hra: 27500,
        da: 8250,
        otherAllowances: 4500,
        grossSalary: 95250,
        address: '456 Marketing Plaza, Mumbai, Maharashtra - 400001',
        emergencyContact: '+91 9876543221',
        bankAccountNumber: '2345678901',
        ifscCode: 'ICICI0002345',
        panNumber: 'BCDEF2345G',
        aadhaarNumber: '2345-6789-0123',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      EmployeeModel(
        id: 'emp3',
        userId: 'emp3',
        employeeId: 'EMP003',
        name: 'Mike Johnson',
        email: 'mike.johnson@company.com',
        phone: '+91 9876543230',
        dateOfBirth: DateTime(1988, 12, 10),
        joinDate: DateTime(2022, 6, 1),
        department: Department.sales,
        designation: 'Sales Director',
        employmentType: EmploymentType.fullTime,
        basicSalary: 80000,
        hra: 40000,
        da: 12000,
        otherAllowances: 8000,
        grossSalary: 140000,
        address: '789 Sales Avenue, Delhi - 110001',
        emergencyContact: '+91 9876543231',
        bankAccountNumber: '3456789012',
        ifscCode: 'SBI0003456',
        panNumber: 'CDEFG3456H',
        aadhaarNumber: '3456-7890-1234',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      EmployeeModel(
        id: 'emp4',
        userId: 'emp4',
        employeeId: 'EMP004',
        name: 'Sarah Wilson',
        email: 'sarah.wilson@company.com',
        phone: '+91 9876543240',
        dateOfBirth: DateTime(1995, 3, 25),
        joinDate: DateTime(2023, 3, 15),
        department: Department.design,
        designation: 'UI/UX Designer',
        employmentType: EmploymentType.fullTime,
        basicSalary: 45000,
        hra: 22500,
        da: 6750,
        otherAllowances: 3500,
        grossSalary: 77750,
        address: '321 Design Hub, Hyderabad, Telangana - 500001',
        emergencyContact: '+91 9876543241',
        bankAccountNumber: '4567890123',
        ifscCode: 'AXIS0004567',
        panNumber: 'DEFGH4567I',
        aadhaarNumber: '4567-8901-2345',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Mock payrolls
  static List<PayrollModel> getMockPayrolls() {
    final employees = getMockEmployees();
    final payrolls = <PayrollModel>[];
    final currentDate = DateTime.now();

    for (final employee in employees) {
      // Generate payrolls for last 3 months
      for (int i = 0; i < 3; i++) {
        final month = currentDate.month - i;
        final year = month <= 0 ? currentDate.year - 1 : currentDate.year;
        final adjustedMonth = month <= 0 ? month + 12 : month;

        final payroll = PayrollModel.calculatePayroll(
          employeeId: employee.id,
          employeeName: employee.name,
          department: employee.department,
          month: adjustedMonth,
          year: year,
          basicSalary: employee.basicSalary,
          hra: employee.hra,
          da: employee.da,
          otherAllowances: employee.otherAllowances,
        );

        payrolls.add(payroll.copyWith(
          id: 'payroll_${employee.id}_${adjustedMonth}_$year',
          status: i == 0 ? PayrollStatus.pending : PayrollStatus.approved,
          processedAt: i == 0 ? null : DateTime.now().subtract(Duration(days: 30 * i)),
          processedBy: i == 0 ? null : 'admin1',
        ));
      }
    }

    return payrolls;
  }

  // Mock payslips
  static List<PayslipModel> getMockPayslips() {
    final employees = getMockEmployees();
    final payslips = <PayslipModel>[];
    final currentDate = DateTime.now();

    for (final employee in employees) {
      // Generate payslips for last 3 months (excluding current pending month)
      for (int i = 1; i < 3; i++) {
        final month = currentDate.month - i;
        final year = month <= 0 ? currentDate.year - 1 : currentDate.year;
        final adjustedMonth = month <= 0 ? month + 12 : month;

        final payroll = PayrollModel.calculatePayroll(
          employeeId: employee.id,
          employeeName: employee.name,
          department: employee.department,
          month: adjustedMonth,
          year: year,
          basicSalary: employee.basicSalary,
          hra: employee.hra,
          da: employee.da,
          otherAllowances: employee.otherAllowances,
        );

        final payslip = PayslipModel.fromPayroll(
          payroll,
          employeeCode: employee.employeeId,
          designation: employee.designation,
          bankAccountNumber: employee.bankAccountNumber,
          ifscCode: employee.ifscCode,
        );

        payslips.add(payslip.copyWith(
          id: 'payslip_${employee.id}_${adjustedMonth}_$year',
        ));
      }
    }

    return payslips;
  }

  // Mock admin dashboard data
  static AdminDashboardData getMockAdminDashboard() {
    final employees = getMockEmployees();
    final payrolls = getMockPayrolls();
    
    final departmentCounts = <Department, int>{};
    final departmentSalaries = <Department, double>{};
    
    for (final employee in employees) {
      departmentCounts[employee.department] = 
          (departmentCounts[employee.department] ?? 0) + 1;
      departmentSalaries[employee.department] = 
          (departmentSalaries[employee.department] ?? 0) + employee.grossSalary;
    }

    final departmentChart = departmentCounts.entries
        .map((entry) => ChartData.fromDepartment(entry.key, entry.value.toDouble()))
        .toList();

    final monthlyExpenseChart = <ChartData>[];
    final currentDate = DateTime.now();
    
    for (int i = 5; i >= 0; i--) {
      final month = currentDate.month - i;
      final year = month <= 0 ? currentDate.year - 1 : currentDate.year;
      final adjustedMonth = month <= 0 ? month + 12 : month;
      
      final monthlyExpense = employees.fold<double>(
        0.0, 
        (sum, emp) => sum + emp.grossSalary,
      );
      
      monthlyExpenseChart.add(ChartData.fromExpense(
        AppUtils.getMonthName(adjustedMonth).substring(0, 3),
        monthlyExpense,
      ));
    }

    final recentActivities = [
      RecentActivity(
        id: '1',
        title: 'Payroll Processed',
        description: 'Monthly payroll for December 2024 has been processed',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: ActivityType.payrollProcessed,
        actionBy: 'Admin User',
      ),
      RecentActivity(
        id: '2',
        title: 'New Employee Added',
        description: 'Sarah Wilson has been added to the system',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: ActivityType.employeeAdded,
        employeeName: 'Sarah Wilson',
        actionBy: 'Admin User',
      ),
      RecentActivity(
        id: '3',
        title: 'Payslips Generated',
        description: '4 payslips generated for November 2024',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: ActivityType.payslipGenerated,
        actionBy: 'Admin User',
      ),
      RecentActivity(
        id: '4',
        title: 'Compliance Report',
        description: 'Monthly compliance report generated',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: ActivityType.complianceReport,
        actionBy: 'Admin User',
      ),
    ];

    final currentMonthSummary = PayrollSummary(
      totalEmployees: employees.length,
      totalGrossSalary: employees.fold(0.0, (sum, emp) => sum + emp.grossSalary),
      totalNetSalary: payrolls
          .where((p) => p.month == currentDate.month && p.year == currentDate.year)
          .fold(0.0, (sum, p) => sum + p.netSalary),
      totalDeductions: payrolls
          .where((p) => p.month == currentDate.month && p.year == currentDate.year)
          .fold(0.0, (sum, p) => sum + p.totalDeductions),
      processedPayrolls: payrolls.where((p) => p.status == PayrollStatus.approved).length,
      pendingPayrolls: payrolls.where((p) => p.status == PayrollStatus.pending).length,
      departmentWiseCount: departmentCounts,
      departmentWiseSalary: departmentSalaries,
      monthlyExpense: {
        for (int i = 5; i >= 0; i--)
          AppUtils.getMonthName(currentDate.month - i <= 0 
              ? currentDate.month - i + 12 
              : currentDate.month - i).substring(0, 3): 
          employees.fold<double>(0.0, (sum, emp) => sum + emp.grossSalary)
      },
    );

    return AdminDashboardData(
      totalEmployees: employees.length,
      activeEmployees: employees.where((e) => e.isActive).length,
      pendingPayrolls: payrolls.where((p) => p.status == PayrollStatus.pending).length,
      monthlyExpense: employees.fold(0.0, (sum, emp) => sum + emp.grossSalary),
      yearlyExpense: employees.fold(0.0, (sum, emp) => sum + emp.grossSalary) * 12,
      departmentChart: departmentChart,
      monthlyExpenseChart: monthlyExpenseChart,
      recentActivities: recentActivities,
      currentMonthSummary: currentMonthSummary,
    );
  }

  // Mock employee dashboard data
  static EmployeeDashboardData getMockEmployeeDashboard(String employeeId) {
    final employees = getMockEmployees();
    final payslips = getMockPayslips();
    final employee = employees.firstWhere((e) => e.id == employeeId);
    final employeePayslips = payslips.where((p) => p.employeeId == employeeId).toList();

    final salaryBreakdown = [
      ChartData(
        label: 'Basic Salary',
        value: employee.basicSalary,
        color: AppColors.chartColors[0].value.toRadixString(16),
      ),
      ChartData(
        label: 'HRA',
        value: employee.hra,
        color: AppColors.chartColors[1].value.toRadixString(16),
      ),
      ChartData(
        label: 'DA',
        value: employee.da,
        color: AppColors.chartColors[2].value.toRadixString(16),
      ),
      ChartData(
        label: 'Other Allowances',
        value: employee.otherAllowances,
        color: AppColors.chartColors[3].value.toRadixString(16),
      ),
    ];

    final yearlyEarnings = <ChartData>[];
    final currentDate = DateTime.now();
    
    for (int i = 11; i >= 0; i--) {
      final month = currentDate.month - i;
      final year = month <= 0 ? currentDate.year - 1 : currentDate.year;
      final adjustedMonth = month <= 0 ? month + 12 : month;
      
      yearlyEarnings.add(ChartData(
        label: AppUtils.getMonthName(adjustedMonth).substring(0, 3),
        value: employee.grossSalary,
        color: AppColors.primaryBlue.value.toRadixString(16),
      ));
    }

    final stats = EmployeeStats(
      totalPayslips: employeePayslips.length,
      currentYear: currentDate.year,
      highestSalary: employee.grossSalary,
      lowestSalary: employee.grossSalary,
      averageSalary: employee.grossSalary,
      workingDays: 22, // Average working days per month
      totalTaxDeducted: employeePayslips.fold(0.0, (sum, p) => sum + p.tdsDeduction),
    );

    return EmployeeDashboardData(
      currentMonthSalary: employee.grossSalary,
      yearToDateSalary: employee.grossSalary * currentDate.month,
      totalDeductions: employeePayslips.fold(0.0, (sum, p) => sum + p.totalDeductions),
      latestPayslip: employeePayslips.isNotEmpty ? employeePayslips.first : null,
      recentPayslips: employeePayslips.take(3).toList(),
      salaryBreakdown: salaryBreakdown,
      yearlyEarnings: yearlyEarnings,
      stats: stats,
    );
  }

  // Mock notifications
  static List<NotificationModel> getMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Payslip Ready',
        message: 'Your payslip for December 2024 is ready to download',
        type: NotificationType.payslip,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '2',
        title: 'Payroll Processed',
        message: 'Your salary for December 2024 has been processed',
        type: NotificationType.payroll,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        id: '3',
        title: 'System Maintenance',
        message: 'Scheduled maintenance on Sunday 2 AM - 4 AM',
        type: NotificationType.system,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Tax Reminder',
        message: 'ITR filing deadline approaching - March 31st',
        type: NotificationType.reminder,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // Mock compliance reports
  static List<ComplianceReport> getMockComplianceReports() {
    final currentDate = DateTime.now();
    final reports = <ComplianceReport>[];

    for (int i = 0; i < 6; i++) {
      final month = currentDate.month - i;
      final year = month <= 0 ? currentDate.year - 1 : currentDate.year;
      final adjustedMonth = month <= 0 ? month + 12 : month;

      reports.add(ComplianceReport(
        id: 'report_${adjustedMonth}_$year',
        title: 'Compliance Report - ${AppUtils.getMonthName(adjustedMonth)} $year',
        month: adjustedMonth,
        year: year,
        totalPfDeduction: 25000.0 + (i * 1000),
        totalEsiDeduction: 8000.0 + (i * 300),
        totalTdsDeduction: 15000.0 + (i * 500),
        employeeCount: 4,
        generatedAt: DateTime.now().subtract(Duration(days: 30 * i)),
        generatedBy: 'Admin User',
      ));
    }

    return reports;
  }

  // Mock quick actions for admin
  static List<QuickAction> getMockAdminQuickActions() {
    return [
      QuickAction(
        title: 'Add Employee',
        subtitle: 'Add new team member',
        icon: '👤',
        route: '/employee-management',
      ),
      QuickAction(
        title: 'Process Payroll',
        subtitle: 'Run monthly payroll',
        icon: '💰',
        route: '/payroll-processing',
        badge: 4, // Pending payrolls
      ),
      QuickAction(
        title: 'Generate Reports',
        subtitle: 'Compliance & analytics',
        icon: '📊',
        route: '/compliance-reports',
      ),
      QuickAction(
        title: 'Employee List',
        subtitle: 'Manage team members',
        icon: '👥',
        route: '/employee-management',
      ),
    ];
  }

  // Mock quick actions for employee
  static List<QuickAction> getMockEmployeeQuickActions() {
    return [
      QuickAction(
        title: 'Latest Payslip',
        subtitle: 'Download current payslip',
        icon: '📄',
        route: '/payslip-viewer',
        badge: 1, // New payslip available
      ),
      QuickAction(
        title: 'Salary History',
        subtitle: 'View past payslips',
        icon: '📈',
        route: '/payslip-viewer',
      ),
      QuickAction(
        title: 'Tax Documents',
        subtitle: 'Download tax forms',
        icon: '🧾',
        route: '/payslip-viewer',
      ),
      QuickAction(
        title: 'Profile',
        subtitle: 'Update personal info',
        icon: '⚙️',
        route: '/profile',
        isEnabled: false, // Not implemented yet
      ),
    ];
  }

  // Helper method to get employee by user ID
  static EmployeeModel? getEmployeeByUserId(String userId) {
    final employees = getMockEmployees();
    try {
      return employees.firstWhere((e) => e.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get user by email
  static UserModel? getUserByEmail(String email) {
    final users = getMockUsers();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get payrolls by employee ID
  static List<PayrollModel> getPayrollsByEmployeeId(String employeeId) {
    final payrolls = getMockPayrolls();
    return payrolls.where((p) => p.employeeId == employeeId).toList();
  }

  // Helper method to get payslips by employee ID
  static List<PayslipModel> getPayslipsByEmployeeId(String employeeId) {
    final payslips = getMockPayslips();
    return payslips.where((p) => p.employeeId == employeeId).toList();
  }
}