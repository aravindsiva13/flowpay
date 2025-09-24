import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.employee,
      ),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class EmployeeModel {
  final String id;
  final String userId; // Reference to UserModel
  final String employeeId; // Unique employee identifier (e.g., EMP001)
  final String name;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final DateTime joinDate;
  final Department department;
  final String designation;
  final EmploymentType employmentType;
  final double basicSalary;
  final double hra;
  final double da; // Dearness Allowance
  final double otherAllowances;
  final double grossSalary;
  final String address;
  final String emergencyContact;
  final String bankAccountNumber;
  final String ifscCode;
  final String panNumber;
  final String aadhaarNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.joinDate,
    required this.department,
    required this.designation,
    required this.employmentType,
    required this.basicSalary,
    required this.hra,
    required this.da,
    this.otherAllowances = 0.0,
    required this.grossSalary,
    required this.address,
    required this.emergencyContact,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.panNumber,
    required this.aadhaarNumber,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: (json['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      joinDate: (json['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      department: Department.values.firstWhere(
        (dept) => dept.name == json['department'],
        orElse: () => Department.engineering,
      ),
      designation: json['designation'] ?? '',
      employmentType: EmploymentType.values.firstWhere(
        (type) => type.name == json['employmentType'],
        orElse: () => EmploymentType.fullTime,
      ),
      basicSalary: (json['basicSalary'] ?? 0.0).toDouble(),
      hra: (json['hra'] ?? 0.0).toDouble(),
      da: (json['da'] ?? 0.0).toDouble(),
      otherAllowances: (json['otherAllowances'] ?? 0.0).toDouble(),
      grossSalary: (json['grossSalary'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      panNumber: json['panNumber'] ?? '',
      aadhaarNumber: json['aadhaarNumber'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'joinDate': Timestamp.fromDate(joinDate),
      'department': department.name,
      'designation': designation,
      'employmentType': employmentType.name,
      'basicSalary': basicSalary,
      'hra': hra,
      'da': da,
      'otherAllowances': otherAllowances,
      'grossSalary': grossSalary,
      'address': address,
      'emergencyContact': emergencyContact,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'panNumber': panNumber,
      'aadhaarNumber': aadhaarNumber,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? userId,
    String? employeeId,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    DateTime? joinDate,
    Department? department,
    String? designation,
    EmploymentType? employmentType,
    double? basicSalary,
    double? hra,
    double? da,
    double? otherAllowances,
    double? grossSalary,
    String? address,
    String? emergencyContact,
    String? bankAccountNumber,
    String? ifscCode,
    String? panNumber,
    String? aadhaarNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      joinDate: joinDate ?? this.joinDate,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      employmentType: employmentType ?? this.employmentType,
      basicSalary: basicSalary ?? this.basicSalary,
      hra: hra ?? this.hra,
      da: da ?? this.da,
      otherAllowances: otherAllowances ?? this.otherAllowances,
      grossSalary: grossSalary ?? this.grossSalary,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      panNumber: panNumber ?? this.panNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate gross salary from basic salary
  static double calculateGrossSalary(double basicSalary) {
    final hra = basicSalary * AppConstants.hraPercentage;
    final da = basicSalary * AppConstants.daPercentage;
    return basicSalary + hra + da;
  }

  // Calculate components from gross salary
  static Map<String, double> calculateSalaryComponents(double grossSalary) {
    final basicSalary = grossSalary * AppConstants.basicSalaryPercentage;
    final hra = basicSalary * AppConstants.hraPercentage;
    final da = basicSalary * AppConstants.daPercentage;
    
    return {
      'basic': basicSalary,
      'hra': hra,
      'da': da,
      'gross': basicSalary + hra + da,
    };
  }

  // Get full name initials
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words.isNotEmpty ? words[0][0].toUpperCase() : '';
  }

  // Get age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Get tenure in months
  int get tenureInMonths {
    final now = DateTime.now();
    final months = (now.year - joinDate.year) * 12 + (now.month - joinDate.month);
    return months;
  }

  // Get display name for employment type
  String get employmentTypeDisplay => employmentType.displayName;

  // Get display name for department
  String get departmentDisplay => department.displayName;
}