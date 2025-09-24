import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/mock_data.dart';
import '../core/constants.dart';

// Employee state
class EmployeeState {
  final List<EmployeeModel> employees;
  final bool isLoading;
  final String? error;
  final EmployeeModel? selectedEmployee;
  final String searchQuery;
  final Department? departmentFilter;

  const EmployeeState({
    this.employees = const [],
    this.isLoading = false,
    this.error,
    this.selectedEmployee,
    this.searchQuery = '',
    this.departmentFilter,
  });

  EmployeeState copyWith({
    List<EmployeeModel>? employees,
    bool? isLoading,
    String? error,
    EmployeeModel? selectedEmployee,
    String? searchQuery,
    Department? departmentFilter,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      searchQuery: searchQuery ?? this.searchQuery,
      departmentFilter: departmentFilter ?? this.departmentFilter,
    );
  }

  // Filtered employees based on search and department filter
  List<EmployeeModel> get filteredEmployees {
    var filtered = employees;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((emp) =>
        emp.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        emp.employeeId.toLowerCase().contains(searchQuery.toLowerCase()) ||
        emp.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
        emp.designation.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Apply department filter
    if (departmentFilter != null) {
      filtered = filtered.where((emp) => emp.department == departmentFilter).toList();
    }

    return filtered;
  }
}

// Employee notifier
class EmployeeNotifier extends StateNotifier<EmployeeState> {
  EmployeeNotifier() : super(const EmployeeState()) {
    loadEmployees();
  }

  // Load all employees
  Future<void> loadEmployees() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      final employees = MockDataService.getMockEmployees();
      
      state = state.copyWith(
        employees: employees,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Add new employee
  Future<void> addEmployee(EmployeeModel employee) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      final newEmployee = employee.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final updatedEmployees = [...state.employees, newEmployee];
      
      state = state.copyWith(
        employees: updatedEmployees,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add employee: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Update employee
  Future<void> updateEmployee(EmployeeModel employee) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      final updatedEmployee = employee.copyWith(updatedAt: DateTime.now());
      
      final updatedEmployees = state.employees.map((emp) =>
        emp.id == employee.id ? updatedEmployee : emp
      ).toList();
      
      state = state.copyWith(
        employees: updatedEmployees,
        isLoading: false,
        selectedEmployee: updatedEmployee,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update employee: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Delete employee
  Future<void> deleteEmployee(String employeeId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      final updatedEmployees = state.employees
          .where((emp) => emp.id != employeeId)
          .toList();
      
      state = state.copyWith(
        employees: updatedEmployees,
        isLoading: false,
        selectedEmployee: state.selectedEmployee?.id == employeeId ? null : state.selectedEmployee,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete employee: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Select employee
  void selectEmployee(EmployeeModel employee) {
    state = state.copyWith(selectedEmployee: employee);
  }

  // Clear selected employee
  void clearSelectedEmployee() {
    state = state.copyWith(selectedEmployee: null);
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set department filter
  void setDepartmentFilter(Department? department) {
    state = state.copyWith(departmentFilter: department);
  }

  // Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      departmentFilter: null,
    );
  }

  // Get employee by ID
  EmployeeModel? getEmployeeById(String id) {
    try {
      return state.employees.firstWhere((emp) => emp.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get employees by department
  List<EmployeeModel> getEmployeesByDepartment(Department department) {
    return state.employees.where((emp) => emp.department == department).toList();
  }

  // Get active employees count
  int get activeEmployeesCount {
    return state.employees.where((emp) => emp.isActive).length;
  }

  // Get department wise count
  Map<Department, int> get departmentWiseCount {
    final counts = <Department, int>{};
    for (final employee in state.employees) {
      counts[employee.department] = (counts[employee.department] ?? 0) + 1;
    }
    return counts;
  }

  // Calculate total salary expense
  double get totalSalaryExpense {
    return state.employees.fold<double>(
      0.0,
      (sum, emp) => sum + emp.grossSalary,
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadEmployees();
  }
}

// Provider
final employeeProvider = StateNotifierProvider<EmployeeNotifier, EmployeeState>((ref) {
  return EmployeeNotifier();
});