import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/payroll_model.dart';
import '../models/user_model.dart';
import '../core/utils.dart';

class PayslipPDFGenerator {
  static Future<Uint8List> generatePayslip({
    required PayslipModel payslip,
    String? companyName,
    String? companyAddress,
    String? companyLogo,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(
              companyName: companyName ?? 'Your Company Name',
              companyAddress: companyAddress ?? 'Company Address',
            ),
            pw.SizedBox(height: 20),
            _buildPayslipTitle(payslip),
            pw.SizedBox(height: 20),
            _buildEmployeeDetails(payslip),
            pw.SizedBox(height: 20),
            _buildSalaryTable(payslip),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader({
    required String companyName,
    required String companyAddress,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#2563EB'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            companyName,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            companyAddress,
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 12,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPayslipTitle(PayslipModel payslip) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          pw.Text(
            'SALARY SLIP',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1E293B'),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'For the month of ${payslip.payPeriod}',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildEmployeeDetails(PayslipModel payslip) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Employee Name', payslip.employeeName),
                _buildDetailRow('Employee ID', payslip.employeeCode),
                _buildDetailRow('Designation', payslip.designation),
                _buildDetailRow('Department', payslip.department.displayName),
              ],
            ),
          ),
          pw.SizedBox(width: 40),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Pay Date', payslip.formattedPayDate),
                _buildDetailRow('Pay Period', payslip.payPeriod),
                _buildDetailRow('Bank A/C', payslip.bankAccountNumber),
                _buildDetailRow('IFSC Code', payslip.ifscCode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex('#64748B'),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1E293B'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSalaryTable(PayslipModel payslip) {
    return pw.Column(
      children: [
        // Earnings section
        _buildTableSection(
          title: 'EARNINGS',
          items: [
            ['Basic Salary', AppUtils.formatCurrency(payslip.basicSalary)],
            ['House Rent Allowance (HRA)', AppUtils.formatCurrency(payslip.hra)],
            ['Dearness Allowance (DA)', AppUtils.formatCurrency(payslip.da)],
            ['Other Allowances', AppUtils.formatCurrency(payslip.otherAllowances)],
          ],
          total: payslip.grossEarnings,
          totalLabel: 'GROSS EARNINGS',
          color: PdfColor.fromHex('#10B981'),
        ),
        
        pw.SizedBox(height: 15),
        
        // Deductions section
        _buildTableSection(
          title: 'DEDUCTIONS',
          items: [
            ['Provident Fund (PF)', AppUtils.formatCurrency(payslip.pfDeduction)],
            ['Employee State Insurance (ESI)', AppUtils.formatCurrency(payslip.esiDeduction)],
            ['Tax Deducted at Source (TDS)', AppUtils.formatCurrency(payslip.tdsDeduction)],
            ['Other Deductions', AppUtils.formatCurrency(payslip.otherDeductions)],
          ],
          total: payslip.totalDeductions,
          totalLabel: 'TOTAL DEDUCTIONS',
          color: PdfColor.fromHex('#EF4444'),
        ),
        
        pw.SizedBox(height: 15),
        
        // Net pay
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#10B981').shade(0.1),
            border: pw.Border.all(color: PdfColor.fromHex('#10B981')),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'NET PAY',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#10B981'),
                ),
              ),
              pw.Text(
                AppUtils.formatCurrency(payslip.netPay),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#10B981'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableSection({
    required String title,
    required List<List<String>> items,
    required double total,
    required String totalLabel,
    required PdfColor color,
  }) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: color.shade(0.1),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ),
          
          // Items
          ...items.map((item) => pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColor.fromHex('#F1F5F9')),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  item[0],
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  item[1],
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
          
          // Total
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  totalLabel,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  AppUtils.formatCurrency(total),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Divider(color: PdfColor.fromHex('#E2E8F0')),
          pw.SizedBox(height: 10),
          pw.Text(
            'Note: This is a computer-generated payslip and does not require a signature.',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('#64748B'),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated on: ${AppUtils.formatFullDateTime(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromHex('#64748B'),
                ),
              ),
              pw.Text(
                'Payroll Management System',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromHex('#64748B'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Compliance Report PDF Generator
class ComplianceReportPDFGenerator {
  static Future<Uint8List> generateComplianceReport({
    required ComplianceReport report,
    required List<PayrollModel> payrolls,
    String? companyName,
    String? companyAddress,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildReportHeader(
              companyName: companyName ?? 'Your Company Name',
              companyAddress: companyAddress ?? 'Company Address',
              report: report,
            ),
            pw.SizedBox(height: 20),
            _buildSummarySection(report),
            pw.SizedBox(height: 20),
            _buildDetailedTable(payrolls),
            pw.SizedBox(height: 20),
            _buildReportFooter(report),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildReportHeader({
    required String companyName,
    required String companyAddress,
    required ComplianceReport report,
  }) {
    return pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#2563EB'),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                companyName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                companyAddress,
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Text(
          'COMPLIANCE REPORT',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1E293B'),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'For the period: ${report.period}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColor.fromHex('#64748B'),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection(ComplianceReport report) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SUMMARY',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1E293B'),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryItem('Total Employees', '${report.employeeCount}'),
              ),
              pw.Expanded(
                child: _buildSummaryItem('PF Deduction', AppUtils.formatCurrency(report.totalPfDeduction)),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryItem('ESI Deduction', AppUtils.formatCurrency(report.totalEsiDeduction)),
              ),
              pw.Expanded(
                child: _buildSummaryItem('TDS Deduction', AppUtils.formatCurrency(report.totalTdsDeduction)),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#10B981').shade(0.1),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL DEDUCTIONS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#10B981'),
                  ),
                ),
                pw.Text(
                  AppUtils.formatCurrency(report.totalDeductions),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#10B981'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromHex('#64748B'),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1E293B'),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDetailedTable(List<PayrollModel> payrolls) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETAILED BREAKDOWN',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1E293B'),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Employee', 'PF', 'ESI', 'TDS', 'Total'],
          data: payrolls.map((payroll) => [
            payroll.employeeName,
            AppUtils.formatCurrency(payroll.pfDeduction),
            AppUtils.formatCurrency(payroll.esiDeduction),
            AppUtils.formatCurrency(payroll.tdsDeduction),
            AppUtils.formatCurrency(payroll.totalDeductions),
          ]).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 10,
          ),
          headerDecoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#2563EB'),
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellHeight: 25,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          border: pw.TableBorder.all(
            color: PdfColor.fromHex('#E2E8F0'),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildReportFooter(ComplianceReport report) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Divider(color: PdfColor.fromHex('#E2E8F0')),
          pw.SizedBox(height: 10),
          pw.Text(
            'Report Details:',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1E293B'),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Generated by: ${report.generatedBy}',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),
          pw.Text(
            'Generated on: ${AppUtils.formatFullDateTime(report.generatedAt)}',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Note: This report is generated automatically by the Payroll Management System.',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('#64748B'),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// CSV Generator for compliance reports
class CSVGenerator {
  static String generatePayrollCSV(List<PayrollModel> payrolls) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Employee ID,Employee Name,Department,Month,Year,Basic Salary,HRA,DA,Other Allowances,Gross Salary,PF Deduction,ESI Deduction,TDS Deduction,Other Deductions,Total Deductions,Net Salary,Status');
    
    // Data rows
    for (final payroll in payrolls) {
      buffer.writeln([
        payroll.employeeId,
        payroll.employeeName,
        payroll.department.displayName,
        payroll.month,
        payroll.year,
        payroll.basicSalary,
        payroll.hra,
        payroll.da,
        payroll.otherAllowances,
        payroll.grossSalary,
        payroll.pfDeduction,
        payroll.esiDeduction,
        payroll.tdsDeduction,
        payroll.otherDeductions,
        payroll.totalDeductions,
        payroll.netSalary,
        payroll.status.displayName,
      ].join(','));
    }
    
    return buffer.toString();
  }

  static String generateComplianceCSV({
    required ComplianceReport report,
    required List<PayrollModel> payrolls,
  }) {
    final buffer = StringBuffer();
    
    // Report header
    buffer.writeln('Compliance Report - ${report.period}');
    buffer.writeln('Generated by: ${report.generatedBy}');
    buffer.writeln('Generated on: ${AppUtils.formatFullDateTime(report.generatedAt)}');
    buffer.writeln('');
    
    // Summary
    buffer.writeln('SUMMARY');
    buffer.writeln('Total Employees,${report.employeeCount}');
    buffer.writeln('Total PF Deduction,${report.totalPfDeduction}');
    buffer.writeln('Total ESI Deduction,${report.totalEsiDeduction}');
    buffer.writeln('Total TDS Deduction,${report.totalTdsDeduction}');
    buffer.writeln('Total Deductions,${report.totalDeductions}');
    buffer.writeln('');
    
    // Detailed breakdown
    buffer.writeln('DETAILED BREAKDOWN');
    buffer.writeln('Employee ID,Employee Name,Department,PF Deduction,ESI Deduction,TDS Deduction,Total Deductions');
    
    for (final payroll in payrolls) {
      buffer.writeln([
        payroll.employeeId,
        payroll.employeeName,
        payroll.department.displayName,
        payroll.pfDeduction,
        payroll.esiDeduction,
        payroll.tdsDeduction,
        payroll.totalDeductions,
      ].join(','));
    }
    
    return buffer.toString();
  }

  static String generateEmployeeCSV(List<EmployeeModel> employees) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Employee ID,Name,Email,Phone,Department,Designation,Employment Type,Join Date,Basic Salary,HRA,DA,Other Allowances,Gross Salary,Bank Account,IFSC Code,PAN Number,Status');
    
    // Data rows
    for (final employee in employees) {
      buffer.writeln([
        employee.employeeId,
        employee.name,
        employee.email,
        employee.phone,
        employee.department.displayName,
        employee.designation,
        employee.employmentType.displayName,
        AppUtils.formatDate(employee.joinDate),
        employee.basicSalary,
        employee.hra,
        employee.da,
        employee.otherAllowances,
        employee.grossSalary,
        employee.bankAccountNumber,
        employee.ifscCode,
        employee.panNumber,
        employee.isActive ? 'Active' : 'Inactive',
      ].join(','));
    }
    
    return buffer.toString();
  }
}

// Utility class for PDF styling
class PDFStyles {
  static pw.TextStyle get headerStyle => pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: PdfColor.fromHex('#1E293B'),
  );

  static pw.TextStyle get subHeaderStyle => pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColor.fromHex('#475569'),
  );

  static pw.TextStyle get bodyStyle => const pw.TextStyle(
    fontSize: 10,
    color: PdfColors.black,
  );

  static pw.TextStyle get captionStyle => pw.TextStyle(
    fontSize: 8,
    color: PdfColor.fromHex('#64748B'),
  );

  static pw.BoxDecoration get cardDecoration => pw.BoxDecoration(
    border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
    borderRadius: pw.BorderRadius.circular(8),
  );

  static pw.BoxDecoration get primaryDecoration => pw.BoxDecoration(
    color: PdfColor.fromHex('#2563EB'),
    borderRadius: pw.BorderRadius.circular(8),
  );

  static pw.BoxDecoration get successDecoration => pw.BoxDecoration(
    color: PdfColor.fromHex('#10B981').shade(0.1),
    border: pw.Border.all(color: PdfColor.fromHex('#10B981')),
    borderRadius: pw.BorderRadius.circular(8),
  );
}