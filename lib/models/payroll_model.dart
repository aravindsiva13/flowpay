import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class PayrollModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final Department department;
  final int month; // 1-12
  final int year;
  final double basicSalary;
  final double hra;
  final double da;
  final double otherAllowances;
  final double grossSalary;
  final double pfDeduction;
  final double esiDeduction;
  final double tdsDeduction;
  final double otherDeductions;
  final double totalDeductions;
  final double netSalary;
  final PayrollStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? notes;

  PayrollModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.hra,
    required this.da,
    this.otherAllowances = 0.0,
    required this.grossSalary,
    required this.pfDeduction,
    required this.esiDeduction,
    required this.tdsDeduction,
    this.otherDeductions = 0.0,
    required this.totalDeductions,
    required this.netSalary,
    this.status = PayrollStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.processedAt,
    this.processedBy,
    this.notes,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      department: Department.values.firstWhere(
        (dept) => dept.name == json['department'],
        orElse: () => Department.engineering,
      ),
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      basicSalary: (json['basicSalary'] ?? 0.0).toDouble(),
      hra: (json['hra'] ?? 0.0).toDouble(),
      da: (json['da'] ?? 0.0).toDouble(),
      otherAllowances: (json['otherAllowances'] ?? 0.0).toDouble(),
      grossSalary: (json['grossSalary'] ?? 0.0).toDouble(),
      pfDeduction: (json['pfDeduction'] ?? 0.0).toDouble(),
      esiDeduction: (json['esiDeduction'] ?? 0.0).toDouble(),
      tdsDeduction: (json['tdsDeduction'] ?? 0.0).toDouble(),
      otherDeductions: (json['otherDeductions'] ?? 0.0).toDouble(),
      totalDeductions: (json['totalDeductions'] ?? 0.0).toDouble(),
      netSalary: (json['netSalary'] ?? 0.0).toDouble(),
      status: PayrollStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PayrollStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt: (json['processedAt'] as Timestamp?)?.toDate(),
      processedBy: json['processedBy'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'department': department.name,
      'month': month,
      'year': year,
      'basicSalary': basicSalary,
      'hra': hra,
      'da': da,
      'otherAllowances': otherAllowances,
      'grossSalary': grossSalary,
      'pfDeduction': pfDeduction,
      'esiDeduction': esiDeduction,
      'tdsDeduction': tdsDeduction,
      'otherDeductions': otherDeductions,
      'totalDeductions': totalDeductions,
      'netSalary': netSalary,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'processedBy': processedBy,
      'notes': notes,
    };
  }

  PayrollModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    Department? department,
    int? month,
    int? year,
    double? basicSalary,
    double? hra,
    double? da,
    double? otherAllowances,
    double? grossSalary,
    double? pfDeduction,
    double? esiDeduction,
    double? tdsDeduction,
    double? otherDeductions,
    double? totalDeductions,
    double? netSalary,
    PayrollStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? processedAt,
    String? processedBy,
    String? notes,
  }) {
    return PayrollModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      month: month ?? this.month,
      year: year ?? this.year,
      basicSalary: basicSalary ?? this.basicSalary,
      hra: hra ?? this.hra,
      da: da ?? this.da,
      otherAllowances: otherAllowances ?? this.otherAllowances,
      grossSalary: grossSalary ?? this.grossSalary,
      pfDeduction: pfDeduction ?? this.pfDeduction,
      esiDeduction: esiDeduction ?? this.esiDeduction,
      tdsDeduction: tdsDeduction ?? this.tdsDeduction,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      netSalary: netSalary ?? this.netSalary,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      notes: notes ?? this.notes,
    );
  }

  // Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Get pay period display
  String get payPeriod => '$monthName $year';

  // Calculate payroll from employee data
  static PayrollModel calculatePayroll({
    required String employeeId,
    required String employeeName,
    required Department department,
    required int month,
    required int year,
    required double basicSalary,
    required double hra,
    required double da,
    double otherAllowances = 0.0,
    double otherDeductions = 0.0,
    String? notes,
  }) {
    final grossSalary = basicSalary + hra + da + otherAllowances;
    
    // Calculate deductions
    final pfDeduction = basicSalary * AppConstants.pfRate;
    final esiDeduction = grossSalary <= 21000 ? grossSalary * AppConstants.esiRate : 0.0;
    
    // Calculate TDS (simplified calculation)
    final annualSalary = grossSalary * 12;
    final tdsDeduction = _calculateTDS(annualSalary) / 12;
    
    final totalDeductions = pfDeduction + esiDeduction + tdsDeduction + otherDeductions;
    final netSalary = grossSalary - totalDeductions;

    return PayrollModel(
      id: '', // Will be generated when saving
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      month: month,
      year: year,
      basicSalary: basicSalary,
      hra: hra,
      da: da,
      otherAllowances: otherAllowances,
      grossSalary: grossSalary,
      pfDeduction: pfDeduction,
      esiDeduction: esiDeduction,
      tdsDeduction: tdsDeduction,
      otherDeductions: otherDeductions,
      totalDeductions: totalDeductions,
      netSalary: netSalary,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: notes,
    );
  }

  // Calculate TDS based on new tax regime
  static double _calculateTDS(double annualSalary) {
    double tax = 0.0;
    double remainingSalary = annualSalary;
    
    for (final entry in AppConstants.taxSlabs.entries) {
      final slabLimit = entry.key;
      final taxRate = entry.value;
      
      if (remainingSalary <= 0) break;
      
      final taxableAmount = slabLimit == double.infinity 
          ? remainingSalary 
          : (remainingSalary > slabLimit ? slabLimit : remainingSalary);
      
      tax += taxableAmount * taxRate;
      remainingSalary -= taxableAmount;
      
      if (slabLimit == double.infinity) break;
    }
    
    return tax;
  }
}

class PayslipModel {
  final String id;
  final String payrollId;
  final String employeeId;
  final String employeeName;
  final String employeeCode;
  final Department department;
  final String designation;
  final int month;
  final int year;
  final DateTime payDate;
  
  // Earnings
  final double basicSalary;
  final double hra;
  final double da;
  final double otherAllowances;
  final double grossEarnings;
  
  // Deductions
  final double pfDeduction;
  final double esiDeduction;
  final double tdsDeduction;
  final double otherDeductions;
  final double totalDeductions;
  
  final double netPay;
  final String bankAccountNumber;
  final String ifscCode;
  final DateTime createdAt;
  final String? pdfUrl; // URL to the generated PDF

  PayslipModel({
    required this.id,
    required this.payrollId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.department,
    required this.designation,
    required this.month,
    required this.year,
    required this.payDate,
    required this.basicSalary,
    required this.hra,
    required this.da,
    required this.otherAllowances,
    required this.grossEarnings,
    required this.pfDeduction,
    required this.esiDeduction,
    required this.tdsDeduction,
    required this.otherDeductions,
    required this.totalDeductions,
    required this.netPay,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.createdAt,
    this.pdfUrl,
  });

  factory PayslipModel.fromPayroll(PayrollModel payroll, {
    required String employeeCode,
    required String designation,
    required String bankAccountNumber,
    required String ifscCode,
    String? pdfUrl,
  }) {
    return PayslipModel(
      id: '', // Will be generated
      payrollId: payroll.id,
      employeeId: payroll.employeeId,
      employeeName: payroll.employeeName,
      employeeCode: employeeCode,
      department: payroll.department,
      designation: designation,
      month: payroll.month,
      year: payroll.year,
      payDate: DateTime.now(),
      basicSalary: payroll.basicSalary,
      hra: payroll.hra,
      da: payroll.da,
      otherAllowances: payroll.otherAllowances,
      grossEarnings: payroll.grossSalary,
      pfDeduction: payroll.pfDeduction,
      esiDeduction: payroll.esiDeduction,
      tdsDeduction: payroll.tdsDeduction,
      otherDeductions: payroll.otherDeductions,
      totalDeductions: payroll.totalDeductions,
      netPay: payroll.netSalary,
      bankAccountNumber: bankAccountNumber,
      ifscCode: ifscCode,
      createdAt: DateTime.now(),
      pdfUrl: pdfUrl,
    );
  }

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      id: json['id'] ?? '',
      payrollId: json['payrollId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      department: Department.values.firstWhere(
        (dept) => dept.name == json['department'],
        orElse: () => Department.engineering,
      ),
      designation: json['designation'] ?? '',
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      payDate: (json['payDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      basicSalary: (json['basicSalary'] ?? 0.0).toDouble(),
      hra: (json['hra'] ?? 0.0).toDouble(),
      da: (json['da'] ?? 0.0).toDouble(),
      otherAllowances: (json['otherAllowances'] ?? 0.0).toDouble(),
      grossEarnings: (json['grossEarnings'] ?? 0.0).toDouble(),
      pfDeduction: (json['pfDeduction'] ?? 0.0).toDouble(),
      esiDeduction: (json['esiDeduction'] ?? 0.0).toDouble(),
      tdsDeduction: (json['tdsDeduction'] ?? 0.0).toDouble(),
      otherDeductions: (json['otherDeductions'] ?? 0.0).toDouble(),
      totalDeductions: (json['totalDeductions'] ?? 0.0).toDouble(),
      netPay: (json['netPay'] ?? 0.0).toDouble(),
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pdfUrl: json['pdfUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payrollId': payrollId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeCode': employeeCode,
      'department': department.name,
      'designation': designation,
      'month': month,
      'year': year,
      'payDate': Timestamp.fromDate(payDate),
      'basicSalary': basicSalary,
      'hra': hra,
      'da': da,
      'otherAllowances': otherAllowances,
      'grossEarnings': grossEarnings,
      'pfDeduction': pfDeduction,
      'esiDeduction': esiDeduction,
      'tdsDeduction': tdsDeduction,
      'otherDeductions': otherDeductions,
      'totalDeductions': totalDeductions,
      'netPay': netPay,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'pdfUrl': pdfUrl,
    };
  }

  // Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Get pay period display
  String get payPeriod => '$monthName $year';

  // Get formatted pay date
  String get formattedPayDate {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(payDate);
  }
}

// Model for dashboard analytics
class PayrollSummary {
  final int totalEmployees;
  final double totalGrossSalary;
  final double totalNetSalary;
  final double totalDeductions;
  final int processedPayrolls;
  final int pendingPayrolls;
  final Map<Department, int> departmentWiseCount;
  final Map<Department, double> departmentWiseSalary;
  final Map<String, double> monthlyExpense; // Last 6 months
  
  PayrollSummary({
    required this.totalEmployees,
    required this.totalGrossSalary,
    required this.totalNetSalary,
    required this.totalDeductions,
    required this.processedPayrolls,
    required this.pendingPayrolls,
    required this.departmentWiseCount,
    required this.departmentWiseSalary,
    required this.monthlyExpense,
  });

  factory PayrollSummary.empty() {
    return PayrollSummary(
      totalEmployees: 0,
      totalGrossSalary: 0.0,
      totalNetSalary: 0.0,
      totalDeductions: 0.0,
      processedPayrolls: 0,
      pendingPayrolls: 0,
      departmentWiseCount: {},
      departmentWiseSalary: {},
      monthlyExpense: {},
    );
  }

  // Calculate savings percentage
  double get savingsPercentage {
    if (totalGrossSalary == 0) return 0.0;
    return (totalDeductions / totalGrossSalary) * 100;
  }

  // Get average salary per employee
  double get averageSalary {
    if (totalEmployees == 0) return 0.0;
    return totalNetSalary / totalEmployees;
  }
}

// Model for compliance reports
class ComplianceReport {
  final String id;
  final String title;
  final int month;
  final int year;
  final double totalPfDeduction;
  final double totalEsiDeduction;
  final double totalTdsDeduction;
  final int employeeCount;
  final DateTime generatedAt;
  final String generatedBy;
  final String? pdfUrl;
  final String? csvUrl;

  ComplianceReport({
    required this.id,
    required this.title,
    required this.month,
    required this.year,
    required this.totalPfDeduction,
    required this.totalEsiDeduction,
    required this.totalTdsDeduction,
    required this.employeeCount,
    required this.generatedAt,
    required this.generatedBy,
    this.pdfUrl,
    this.csvUrl,
  });

  factory ComplianceReport.fromJson(Map<String, dynamic> json) {
    return ComplianceReport(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      totalPfDeduction: (json['totalPfDeduction'] ?? 0.0).toDouble(),
      totalEsiDeduction: (json['totalEsiDeduction'] ?? 0.0).toDouble(),
      totalTdsDeduction: (json['totalTdsDeduction'] ?? 0.0).toDouble(),
      employeeCount: json['employeeCount'] ?? 0,
      generatedAt: (json['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      generatedBy: json['generatedBy'] ?? '',
      pdfUrl: json['pdfUrl'],
      csvUrl: json['csvUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'month': month,
      'year': year,
      'totalPfDeduction': totalPfDeduction,
      'totalEsiDeduction': totalEsiDeduction,
      'totalTdsDeduction': totalTdsDeduction,
      'employeeCount': employeeCount,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'generatedBy': generatedBy,
      'pdfUrl': pdfUrl,
      'csvUrl': csvUrl,
    };
  }

  // Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Get period display
  String get period => '$monthName $year';

  // Get total deductions
  double get totalDeductions => totalPfDeduction + totalEsiDeduction + totalTdsDeduction;
}