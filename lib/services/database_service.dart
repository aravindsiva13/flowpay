import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/payroll_model.dart';
import 'mock_data.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // For development - toggle between mock and real Firebase
  static const bool useMockData = true;

  // Collections
  static const String usersCollection = 'users';
  static const String employeesCollection = 'employees';
  static const String payrollsCollection = 'payrolls';
  static const String payslipsCollection = 'payslips';
  static const String complianceReportsCollection = 'compliance_reports';

  // User operations
  Future<void> createUser(UserModel user) async {
    if (useMockData) return;
    
    try {
      await _firestore.collection(usersCollection).doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    if (useMockData) {
      return MockDataService.getMockUsers().firstWhere(
        (u) => u.id == userId,
        orElse: () => MockDataService.getMockUsers().first,
      );
    }
    
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUser(UserModel user) async {
    if (useMockData) return;
    
    try {
      await _firestore.collection(usersCollection).doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // Employee operations
  Future<void> createEmployee(EmployeeModel employee) async {
    if (useMockData) return;
    
    try {
      await _firestore.collection(employeesCollection).doc(employee.id).set(employee.toJson());
    } catch (e) {
      throw Exception('Failed to create employee: ${e.toString()}');
    }
  }

  Future<List<EmployeeModel>> getEmployees() async {
    if (useMockData) {
      return MockDataService.getMockEmployees();
    }
    
    try {
      final snapshot = await _firestore.collection(employeesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => 
        EmployeeModel.fromJson({...doc.data(), 'id': doc.id})
      ).toList();
    } catch (e) {
      throw Exception('Failed to get employees: ${e.toString()}');
    }
  }

  Stream<List<EmployeeModel>> employeesStream() {
    if (useMockData) {
      return Stream.value(MockDataService.getMockEmployees());
    }
    
    return _firestore.collection(employeesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => 
          EmployeeModel.fromJson({...doc.data(), 'id': doc.id})
        ).toList());
  }

  Future<EmployeeModel?> getEmployee(String employeeId) async {
    if (useMockData) {
      try {
        return MockDataService.getMockEmployees().firstWhere(
          (emp) => emp.id == employeeId,
        );
      } catch (e) {
        return null;
      }
    }
    
    try {
      final doc = await _firestore.collection(employeesCollection).doc(employeeId).get();
      if (doc.exists && doc.data() != null) {
        return EmployeeModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get employee: ${e.toString()}');
    }
  }

  Future<void> updateEmployee(EmployeeModel employee) async {
    if (useMockData) return;
    
    try {
      await _firestore.collection(employeesCollection).doc(employee.id).update(employee.toJson());
    } catch (e) {
      throw Exception('Failed to update employee: ${e.toString()}');
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    if (useMockData) return;
    
    try {
      // Soft delete - mark as inactive
      await _firestore.collection(employeesCollection).doc(employeeId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to delete employee: ${e.toString()}');
    }
  }

  // Payroll operations
  Future<String> createPayroll(PayrollModel payroll) async {
    if (useMockData) return 'mock_payroll_id';
    
    try {
      final docRef = await _firestore.collection(payrollsCollection).add(payroll.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create payroll: ${e.toString()}');
    }
  }

  Future<List<PayrollModel>> getPayrolls({
    int? month,
    int? year,
    String? employeeId,
  }) async {
    if (useMockData) {
      var payrolls = MockDataService.getMockPayrolls();
      
      if (month != null) {
        payrolls = payrolls.where((p) => p.month == month).toList();
      }
      if (year != null) {
        payrolls = payrolls.where((p) => p.year == year).toList();
      }
      if (employeeId != null) {
        payrolls = payrolls.where((p) => p.employeeId == employeeId).toList();
      }
      
      return payrolls;
    }
    
    try {
      Query query = _firestore.collection(payrollsCollection);
      
      if (month != null) {
        query = query.where('month', isEqualTo: month);
      }
      if (year != null) {
        query = query.where('year', isEqualTo: year);
      }
      if (employeeId != null) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }
      
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      
      return snapshot.docs.map((doc) => 
        PayrollModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})
      ).toList();
    } catch (e) {
      throw Exception('Failed to get payrolls: ${e.toString()}');
    }
  }

  Stream<List<PayrollModel>> payrollsStream({
    int? month,
    int? year,
    String? employeeId,
  }) {
    if (useMockData) {
      return Stream.value(MockDataService.getMockPayrolls());
    }
    
    Query query = _firestore.collection(payrollsCollection);
    
    if (month != null) {
      query = query.where('month', isEqualTo: month);
    }
    if (year != null) {
      query = query.where('year', isEqualTo: year);
    }
    if (employeeId != null) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }
    
    return query.orderBy('createdAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => 
          PayrollModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})
        ).toList());
  }

  Future<void> updatePayroll(PayrollModel payroll) async {
    if (useMockData) return;
    
    try {
      await _firestore.collection(payrollsCollection).doc(payroll.id).update(payroll.toJson());
    } catch (e) {
      throw Exception('Failed to update payroll: ${e.toString()}');
    }
  }

  Future<void> bulkUpdatePayrolls(List<PayrollModel> payrolls) async {
    if (useMockData) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final payroll in payrolls) {
        final docRef = _firestore.collection(payrollsCollection).doc(payroll.id);
        batch.update(docRef, payroll.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk update payrolls: ${e.toString()}');
    }
  }

  // Payslip operations
  Future<String> createPayslip(PayslipModel payslip) async {
    if (useMockData) return 'mock_payslip_id';
    
    try {
      final docRef = await _firestore.collection(payslipsCollection).add(payslip.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create payslip: ${e.toString()}');
    }
  }

  Future<List<PayslipModel>> getPayslips({
    String? employeeId,
    int? month,
    int? year,
  }) async {
    if (useMockData) {
      var payslips = MockDataService.getMockPayslips();
      
      if (employeeId != null) {
        payslips = payslips.where((p) => p.employeeId == employeeId).toList();
      }
      if (month != null) {
        payslips = payslips.where((p) => p.month == month).toList();
      }
      if (year != null) {
        payslips = payslips.where((p) => p.year == year).toList();
      }
      
      return payslips;
    }
    
    try {
      Query query = _firestore.collection(payslipsCollection);
      
      if (employeeId != null) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }
      if (month != null) {
        query = query.where('month', isEqualTo: month);
      }
      if (year != null) {
        query = query.where('year', isEqualTo: year);
      }
      
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      
      return snapshot.docs.map((doc) => 
        PayslipModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})
      ).toList();
    } catch (e) {
      throw Exception('Failed to get payslips: ${e.toString()}');
    }
  }

  Stream<List<PayslipModel>> payslipsStream({
    String? employeeId,
    int? month,
    int? year,
  }) {
    if (useMockData) {
      return Stream.value(MockDataService.getMockPayslips());
    }
    
    Query query = _firestore.collection(payslipsCollection);
    
    if (employeeId != null) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }
    if (month != null) {
      query = query.where('month', isEqualTo: month);
    }
    if (year != null) {
      query = query.where('year', isEqualTo: year);
    }
    
    return query.orderBy('createdAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => 
          PayslipModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})
        ).toList());
  }

  // Compliance reports operations
  Future<String> createComplianceReport(ComplianceReport report) async {
    if (useMockData) return 'mock_report_id';
    
    try {
      final docRef = await _firestore.collection(complianceReportsCollection).add(report.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create compliance report: ${e.toString()}');
    }
  }

  Future<List<ComplianceReport>> getComplianceReports() async {
    if (useMockData) {
      return MockDataService.getMockComplianceReports();
    }
    
    try {
      final snapshot = await _firestore.collection(complianceReportsCollection)
          .orderBy('generatedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => 
        ComplianceReport.fromJson({...doc.data(), 'id': doc.id})
      ).toList();
    } catch (e) {
      throw Exception('Failed to get compliance reports: ${e.toString()}');
    }
  }

  Stream<List<ComplianceReport>> complianceReportsStream() {
    if (useMockData) {
      return Stream.value(MockDataService.getMockComplianceReports());
    }
    
    return _firestore.collection(complianceReportsCollection)
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => 
          ComplianceReport.fromJson({...doc.data(), 'id': doc.id})
        ).toList());
  }

  // Search operations
  Future<List<EmployeeModel>> searchEmployees(String query) async {
    if (useMockData) {
      final employees = MockDataService.getMockEmployees();
      return employees.where((emp) =>
        emp.name.toLowerCase().contains(query.toLowerCase()) ||
        emp.employeeId.toLowerCase().contains(query.toLowerCase()) ||
        emp.email.toLowerCase().contains(query.toLowerCase()) ||
        emp.designation.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    try {
      // Firestore doesn't support full-text search natively
      // This is a simplified version - in production, you might want to use
      // Algolia, Elasticsearch, or implement compound queries
      
      final snapshot = await _firestore.collection(employeesCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      final employees = snapshot.docs.map((doc) => 
        EmployeeModel.fromJson({...doc.data(), 'id': doc.id})
      ).toList();
      
      // Client-side filtering
      return employees.where((emp) =>
        emp.name.toLowerCase().contains(query.toLowerCase()) ||
        emp.employeeId.toLowerCase().contains(query.toLowerCase()) ||
        emp.email.toLowerCase().contains(query.toLowerCase()) ||
        emp.designation.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search employees: ${e.toString()}');
    }
  }

  // Analytics operations
  Future<Map<String, dynamic>> getDashboardAnalytics({
    int? month,
    int? year,
  }) async {
    if (useMockData) {
      return MockDataService.getMockAdminDashboard().toAnalyticsMap();
    }
    
    try {
      // Get employees
      final employees = await getEmployees();
      
      // Get payrolls for the period
      final payrolls = await getPayrolls(month: month, year: year);
      
      // Calculate analytics
      final totalEmployees = employees.length;
      final activeEmployees = employees.where((e) => e.isActive).length;
      final processedPayrolls = payrolls.where((p) => p.status == PayrollStatus.approved).length;
      final pendingPayrolls = payrolls.where((p) => p.status == PayrollStatus.pending).length;
      final totalExpense = payrolls.fold<double>(0.0, (sum, p) => sum + p.netSalary);
      
      return {
        'totalEmployees': totalEmployees,
        'activeEmployees': activeEmployees,
        'processedPayrolls': processedPayrolls,
        'pendingPayrolls': pendingPayrolls,
        'totalExpense': totalExpense,
        'averageSalary': totalEmployees > 0 ? totalExpense / totalEmployees : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get dashboard analytics: ${e.toString()}');
    }
  }

  // Backup operations
  Future<void> backupData() async {
    if (useMockData) return;
    
    try {
      // Implementation for backing up data
      // This could export data to Cloud Storage or another backup service
    } catch (e) {
      throw Exception('Failed to backup data: ${e.toString()}');
    }
  }

  // Batch operations
  Future<void> batchCreatePayrolls(List<PayrollModel> payrolls) async {
    if (useMockData) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final payroll in payrolls) {
        final docRef = _firestore.collection(payrollsCollection).doc();
        batch.set(docRef, payroll.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create payrolls: ${e.toString()}');
    }
  }

  Future<void> batchCreatePayslips(List<PayslipModel> payslips) async {
    if (useMockData) return;
    
    try {
      final batch = _firestore.batch();
      
      for (final payslip in payslips) {
        final docRef = _firestore.collection(payslipsCollection).doc();
        batch.set(docRef, payslip.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create payslips: ${e.toString()}');
    }
  }
}

// Extension for analytics conversion
extension AdminDashboardAnalytics on AdminDashboardData {
  Map<String, dynamic> toAnalyticsMap() {
    return {
      'totalEmployees': totalEmployees,
      'activeEmployees': activeEmployees,
      'pendingPayrolls': pendingPayrolls,
      'processedPayrolls': 0, // Would be calculated from payrolls
      'totalExpense': monthlyExpense,
      'averageSalary': totalEmployees > 0 ? monthlyExpense / totalEmployees : 0.0,
    };
  }
}