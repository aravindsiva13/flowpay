import '../models/user_model.dart';
import '../models/payroll_model.dart';
import '../core/constants.dart';
import 'mock_data.dart';

class PayrollService {
  // For development - toggle between mock and real data
  static const bool useMockData = true;

  // Calculate payroll for an employee
  static PayrollModel calculateEmployeePayroll({
    required EmployeeModel employee,
    required int month,
    required int year,
    double? overrideBasicSalary,
    double? overrideAllowances,
    double? additionalDeductions,
    String? notes,
  }) {
    final basicSalary = overrideBasicSalary ?? employee.basicSalary;
    final hra = basicSalary * AppConstants.hraPercentage;
    final da = basicSalary * AppConstants.daPercentage;
    final otherAllowances = overrideAllowances ?? employee.otherAllowances;
    
    return PayrollModel.calculatePayroll(
      employeeId: employee.id,
      employeeName: employee.name,
      department: employee.department,
      month: month,
      year: year,
      basicSalary: basicSalary,
      hra: hra,
      da: da,
      otherAllowances: otherAllowances,
      otherDeductions: additionalDeductions ?? 0.0,
      notes: notes,
    );
  }

  // Calculate bulk payroll for all employees
  static List<PayrollModel> calculateBulkPayroll({
    required List<EmployeeModel> employees,
    required int month,
    required int year,
    Map<String, double>? salaryOverrides,
    Map<String, double>? allowanceOverrides,
    Map<String, double>? deductionOverrides,
    String? globalNotes,
  }) {
    return employees.map((employee) {
      final overrideBasic = salaryOverrides?[employee.id];
      final overrideAllowance = allowanceOverrides?[employee.id];
      final additionalDeduction = deductionOverrides?[employee.id];

      return calculateEmployeePayroll(
        employee: employee,
        month: month,
        year: year,
        overrideBasicSalary: overrideBasic,
        overrideAllowances: overrideAllowance,
        additionalDeductions: additionalDeduction,
        notes: globalNotes,
      );
    }).toList();
  }

  // Calculate PF deduction
  static double calculatePF(double basicSalary) {
    return basicSalary * AppConstants.pfRate;
  }

  // Calculate ESI deduction
  static double calculateESI(double grossSalary) {
    // ESI is applicable only if gross salary <= 21,000
    if (grossSalary <= 21000) {
      return grossSalary * AppConstants.esiRate;
    }
    return 0.0;
  }

  // Calculate TDS based on new tax regime (simplified)
  static double calculateTDS(double annualSalary) {
    double tax = 0.0;
    double remainingSalary = annualSalary;

    // Standard deduction (₹50,000)
    remainingSalary -= 50000;
    if (remainingSalary <= 0) return 0.0;

    for (final entry in AppConstants.taxSlabs.entries) {
      final slabLimit = entry.key;
      final taxRate = entry.value;

      if (remainingSalary <= 0) break;

      double taxableAmount;
      if (slabLimit == double.infinity) {
        taxableAmount = remainingSalary;
      } else {
        taxableAmount = remainingSalary > slabLimit ? slabLimit : remainingSalary;
        if (tax == 0 && slabLimit > 0) {
          // First slab after exemption
          taxableAmount = remainingSalary > (slabLimit - (entry.key == 250000 ? 0 : 250000)) 
              ? (slabLimit - (entry.key == 250000 ? 0 : 250000)) 
              : remainingSalary;
        }
      }

      tax += taxableAmount * taxRate;
      remainingSalary -= taxableAmount;

      if (slabLimit == double.infinity) break;
    }

    // Monthly TDS
    return tax / 12;
  }

  // Calculate net salary
  static double calculateNetSalary({
    required double grossSalary,
    required double pfDeduction,
    required double esiDeduction,
    required double tdsDeduction,
    double otherDeductions = 0.0,
  }) {
    final totalDeductions = pfDeduction + esiDeduction + tdsDeduction + otherDeductions;
    return grossSalary - totalDeductions;
  }

  // Get salary components breakdown
  static Map<String, double> getSalaryComponentsFromBasic(double basicSalary) {
    return {
      'basic': basicSalary,
      'hra': basicSalary * AppConstants.hraPercentage,
      'da': basicSalary * AppConstants.daPercentage,
    };
  }

  // Get salary components from gross
  static Map<String, double> getSalaryComponentsFromGross(double grossSalary) {
    final basicPercentage = AppConstants.basicSalaryPercentage;
    final basic = grossSalary * basicPercentage;
    final hra = basic * AppConstants.hraPercentage;
    final da = basic * AppConstants.daPercentage;
    
    return {
      'basic': basic,
      'hra': hra,
      'da': da,
      'others': grossSalary - (basic + hra + da),
    };
  }

  // Validate salary components
  static bool validateSalaryComponents({
    required double basicSalary,
    required double hra,
    required double da,
    double otherAllowances = 0.0,
  }) {
    if (basicSalary <= 0) return false;
    if (hra < 0 || da < 0 || otherAllowances < 0) return false;
    
    // Check if HRA and DA are reasonable percentages of basic
    final expectedHra = basicSalary * AppConstants.hraPercentage;
    final expectedDa = basicSalary * AppConstants.daPercentage;
    
    // Allow 10% variance
    final hraVariance = (hra - expectedHra).abs() / expectedHra;
    final daVariance = (da - expectedDa).abs() / expectedDa;
    
    return hraVariance <= 0.1 && daVariance <= 0.1;
  }

  // Calculate arrears (back payment)
  static double calculateArrears({
    required double oldSalary,
    required double newSalary,
    required int months,
  }) {
    return (newSalary - oldSalary) * months;
  }

  // Calculate overtime pay
  static double calculateOvertimePay({
    required double hourlyRate,
    required double overtimeHours,
    double overtimeMultiplier = 2.0,
  }) {
    return hourlyRate * overtimeHours * overtimeMultiplier;
  }

  // Calculate bonus
  static double calculateBonus({
    required double basicSalary,
    required int months, // Number of months worked
    double bonusPercentage = 0.0833, // 8.33% (statutory minimum)
  }) {
    if (months < 12) return 0.0;
    return basicSalary * bonusPercentage;
  }

  // Calculate gratuity
  static double calculateGratuity({
    required double lastDrawnSalary,
    required int yearsOfService,
    required int daysWorkedInLastYear,
  }) {
    if (yearsOfService < 5) return 0.0;
    
    // Formula: (Basic + DA) × 15/26 × Years of service
    const gratuityRate = 15.0 / 26.0;
    
    double gratuity = lastDrawnSalary * gratuityRate * yearsOfService;
    
    // Adjust for incomplete year
    if (daysWorkedInLastYear > 0 && daysWorkedInLastYear < 365) {
      final incompleteYearGratuity = (lastDrawnSalary * gratuityRate * daysWorkedInLastYear) / 365;
      gratuity += incompleteYearGratuity;
    }
    
    return gratuity;
  }

  // Get payroll summary for a month
  static PayrollSummary calculatePayrollSummary({
    required List<PayrollModel> payrolls,
    required List<EmployeeModel> employees,
  }) {
    if (payrolls.isEmpty) return PayrollSummary.empty();

    final totalGross = payrolls.fold<double>(0.0, (sum, p) => sum + p.grossSalary);
    final totalNet = payrolls.fold<double>(0.0, (sum, p) => sum + p.netSalary);
    final totalDeductions = payrolls.fold<double>(0.0, (sum, p) => sum + p.totalDeductions);
    
    final processedCount = payrolls.where((p) => p.status == PayrollStatus.approved).length;
    final pendingCount = payrolls.where((p) => p.status == PayrollStatus.pending).length;

    // Department-wise analysis
    final departmentCount = <Department, int>{};
    final departmentSalary = <Department, double>{};
    
    for (final employee in employees) {
      departmentCount[employee.department] = 
          (departmentCount[employee.department] ?? 0) + 1;
      departmentSalary[employee.department] = 
          (departmentSalary[employee.department] ?? 0) + employee.grossSalary;
    }

    // Monthly expense (last 6 months mock data)
    final monthlyExpense = <String, double>{};
    final currentDate = DateTime.now();
    
    for (int i = 5; i >= 0; i--) {
      final month = currentDate.month - i;
      final adjustedMonth = month <= 0 ? month + 12 : month;
      final monthName = _getMonthName(adjustedMonth).substring(0, 3);
      
      // For mock data, use current total as base
      monthlyExpense[monthName] = totalGross + (i * 5000); // Simulate growth
    }

    return PayrollSummary(
      totalEmployees: employees.length,
      totalGrossSalary: totalGross,
      totalNetSalary: totalNet,
      totalDeductions: totalDeductions,
      processedPayrolls: processedCount,
      pendingPayrolls: pendingCount,
      departmentWiseCount: departmentCount,
      departmentWiseSalary: departmentSalary,
      monthlyExpense: monthlyExpense,
    );
  }

  // Calculate year-to-date summary for an employee
  static Map<String, double> calculateYTDSummary({
    required String employeeId,
    required int currentYear,
    required List<PayrollModel> payrolls,
  }) {
    final employeePayrolls = payrolls
        .where((p) => p.employeeId == employeeId && p.year == currentYear)
        .toList();

    if (employeePayrolls.isEmpty) {
      return {
        'grossEarnings': 0.0,
        'totalDeductions': 0.0,
        'netPay': 0.0,
        'pfDeducted': 0.0,
        'esiDeducted': 0.0,
        'tdsDeducted': 0.0,
      };
    }

    return {
      'grossEarnings': employeePayrolls.fold<double>(0.0, (sum, p) => sum + p.grossSalary),
      'totalDeductions': employeePayrolls.fold<double>(0.0, (sum, p) => sum + p.totalDeductions),
      'netPay': employeePayrolls.fold<double>(0.0, (sum, p) => sum + p.netSalary),
      'pfDeducted': employeePayrolls.fold<double>(0.0, (sum, p) => sum + p.pfDeduction),
      'esiDeducted': employeePayrolls.fold<double>(0.0, (sum, p) => sum + p.esiDeduction),
      'tdsDeducted': employeePayrolls.fold<double>(0.0, (sum, p) => sum + p.tdsDeduction),
    };
  }

  // Generate compliance data
  static Map<String, dynamic> generateComplianceData({
    required List<PayrollModel> payrolls,
    required int month,
    required int year,
  }) {
    final filteredPayrolls = payrolls
        .where((p) => p.month == month && p.year == year)
        .toList();

    if (filteredPayrolls.isEmpty) {
      return {
        'totalPF': 0.0,
        'totalESI': 0.0,
        'totalTDS': 0.0,
        'employeeCount': 0,
        'pfEmployees': <Map<String, dynamic>>[],
        'esiEmployees': <Map<String, dynamic>>[],
        'tdsEmployees': <Map<String, dynamic>>[],
      };
    }

    final pfEmployees = <Map<String, dynamic>>[];
    final esiEmployees = <Map<String, dynamic>>[];
    final tdsEmployees = <Map<String, dynamic>>[];

    double totalPF = 0.0;
    double totalESI = 0.0;
    double totalTDS = 0.0;

    for (final payroll in filteredPayrolls) {
      // PF data
      if (payroll.pfDeduction > 0) {
        totalPF += payroll.pfDeduction;
        pfEmployees.add({
          'employeeId': payroll.employeeId,
          'employeeName': payroll.employeeName,
          'basicSalary': payroll.basicSalary,
          'pfDeduction': payroll.pfDeduction,
        });
      }

      // ESI data
      if (payroll.esiDeduction > 0) {
        totalESI += payroll.esiDeduction;
        esiEmployees.add({
          'employeeId': payroll.employeeId,
          'employeeName': payroll.employeeName,
          'grossSalary': payroll.grossSalary,
          'esiDeduction': payroll.esiDeduction,
        });
      }

      // TDS data
      if (payroll.tdsDeduction > 0) {
        totalTDS += payroll.tdsDeduction;
        tdsEmployees.add({
          'employeeId': payroll.employeeId,
          'employeeName': payroll.employeeName,
          'grossSalary': payroll.grossSalary,
          'tdsDeduction': payroll.tdsDeduction,
        });
      }
    }

    return {
      'totalPF': totalPF,
      'totalESI': totalESI,
      'totalTDS': totalTDS,
      'employeeCount': filteredPayrolls.length,
      'pfEmployees': pfEmployees,
      'esiEmployees': esiEmployees,
      'tdsEmployees': tdsEmployees,
      'month': month,
      'year': year,
      'monthName': _getMonthName(month),
    };
  }

  // Validate payroll data before processing
  static List<String> validatePayrollData(List<PayrollModel> payrolls) {
    final errors = <String>[];

    for (final payroll in payrolls) {
      // Check for negative values
      if (payroll.basicSalary <= 0) {
        errors.add('${payroll.employeeName}: Basic salary must be positive');
      }
      
      if (payroll.grossSalary <= 0) {
        errors.add('${payroll.employeeName}: Gross salary must be positive');
      }

      if (payroll.netSalary < 0) {
        errors.add('${payroll.employeeName}: Net salary cannot be negative');
      }

      // Check if deductions are reasonable
      final deductionPercentage = (payroll.totalDeductions / payroll.grossSalary) * 100;
      if (deductionPercentage > 50) {
        errors.add('${payroll.employeeName}: Deductions exceed 50% of gross salary');
      }

      // Check PF calculation
      final expectedPF = payroll.basicSalary * AppConstants.pfRate;
      if ((payroll.pfDeduction - expectedPF).abs() > 1) {
        errors.add('${payroll.employeeName}: PF calculation mismatch');
      }

      // Check ESI calculation
      if (payroll.grossSalary <= 21000) {
        final expectedESI = payroll.grossSalary * AppConstants.esiRate;
        if ((payroll.esiDeduction - expectedESI).abs() > 1) {
          errors.add('${payroll.employeeName}: ESI calculation mismatch');
        }
      } else if (payroll.esiDeduction > 0) {
        errors.add('${payroll.employeeName}: ESI should not be deducted for salary > 21000');
      }
    }

    return errors;
  }

  // Helper method to get month name
  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Calculate pay period dates
  static Map<String, DateTime> getPayPeriodDates(int month, int year) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Last day of month
    
    return {
      'startDate': startDate,
      'endDate': endDate,
      'payDate': endDate.add(const Duration(days: 3)), // Pay 3 days after month end
    };
  }

  // Calculate working days in a month
  static int calculateWorkingDays(int month, int year) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    int workingDays = 0;
    for (DateTime date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); 
         date = date.add(const Duration(days: 1))) {
      // Skip weekends (Saturday = 6, Sunday = 7)
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        workingDays++;
      }
    }
    
    return workingDays;
  }

  // Calculate per day salary
  static double calculatePerDaySalary(double monthlySalary, int workingDays) {
    if (workingDays <= 0) return 0.0;
    return monthlySalary / workingDays;
  }

  // Calculate prorated salary for partial month
  static double calculateProratedSalary({
    required double monthlySalary,
    required int daysWorked,
    required int totalWorkingDays,
  }) {
    if (totalWorkingDays <= 0) return 0.0;
    return (monthlySalary / totalWorkingDays) * daysWorked;
  }
}