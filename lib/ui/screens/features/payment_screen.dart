import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final bool isAdmin;

  const PaymentScreen({super.key, this.isAdmin = true});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddPaymentSheet(BuildContext context, Color themeColor, {bool isStudentSelfPay = false}) {
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    final studentCtrl = TextEditingController(text: isStudentSelfPay ? (user?.name ?? '') : '');
    final roomCtrl = TextEditingController(text: isStudentSelfPay ? (user?.room ?? '') : '');
    final amountCtrl = TextEditingController(text: '3000');
    final trxCtrl = TextEditingController();
    String selectedMethod = 'bKash';
    String selectedMonth = 'May 2025';
    bool isPaid = true;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isStudentSelfPay ? 'Pay Hostel Rent / Submit Receipt' : 'Record Student Payment',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isStudentSelfPay
                            ? 'Enter payment details and transaction ID to submit your rent'
                            : 'Log rent or fees collection from hostel resident',
                        style: const TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                      const SizedBox(height: 14),

                      // Month Selector
                      const Text(
                        'Billing Month',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMonth,
                            isExpanded: true,
                            items: [
                              'January 2025',
                              'February 2025',
                              'March 2025',
                              'April 2025',
                              'May 2025',
                              'June 2025',
                              'July 2025',
                              'August 2025',
                              'September 2025',
                              'October 2025',
                              'November 2025',
                              'December 2025'
                            ].map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() => selectedMonth = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Student Name
                      _buildPaymentInput(
                        controller: studentCtrl,
                        label: 'Student Name',
                        hint: 'e.g. Tanvir Ahmed',
                        readOnly: isStudentSelfPay && studentCtrl.text.isNotEmpty,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Student name is required' : null,
                      ),
                      const SizedBox(height: 10),

                      // Room Number
                      _buildPaymentInput(
                        controller: roomCtrl,
                        label: 'Room Number',
                        hint: 'e.g. 101A',
                        readOnly: isStudentSelfPay && roomCtrl.text.isNotEmpty,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Room is required' : null,
                      ),
                      const SizedBox(height: 10),

                      // Amount Input
                      _buildPaymentInput(
                        controller: amountCtrl,
                        label: 'Amount to Pay (৳)',
                        hint: 'e.g. 3000',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Amount is required' : null,
                      ),
                      const SizedBox(height: 10),

                      // Payment Method Selector
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: ['bKash', 'Nagad', 'Rocket', 'Bank Transfer', 'Cash'].map((m) {
                          final isSel = selectedMethod == m;
                          return ChoiceChip(
                            label: Text(m, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.navy)),
                            selected: isSel,
                            selectedColor: themeColor,
                            backgroundColor: const Color(0xFFF4F8FC),
                            onSelected: (val) {
                              if (val) setSheetState(() => selectedMethod = m);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Transaction ID
                      _buildPaymentInput(
                        controller: trxCtrl,
                        label: 'Transaction ID / Reference',
                        hint: selectedMethod == 'Cash' ? 'e.g. Paid in Hand to Warden' : 'e.g. TRX89234821',
                      ),
                      const SizedBox(height: 10),

                      // If Admin: Paid vs Due toggle
                      if (!isStudentSelfPay) ...[
                        Row(
                          children: [
                            Checkbox(
                              value: isPaid,
                              activeColor: AppColors.green,
                              onChanged: (val) {
                                setSheetState(() => isPaid = val ?? true);
                              },
                            ),
                            Text(
                              isPaid ? 'Payment Confirmed (PAID)' : 'Pending Payment (DUE)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isPaid ? AppColors.green : AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 1,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final newPay = PaymentItem(
                                id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                                receiptNo: 'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                userId: user?.id ?? '',
                                studentName: studentCtrl.text.trim(),
                                room: roomCtrl.text.trim().startsWith('Room')
                                    ? roomCtrl.text.trim()
                                    : 'Room ${roomCtrl.text.trim()}',
                                amount: double.tryParse(amountCtrl.text.trim()) ?? 3000.0,
                                date: 'Today',
                                isPaid: isStudentSelfPay ? true : isPaid,
                                month: selectedMonth,
                                method: selectedMethod,
                                trxId: trxCtrl.text.trim(),
                              );

                              Provider.of<AppProvider>(context, listen: false).addPayment(newPay);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Payment receipt ${newPay.receiptNo} logged successfully!'),
                                  backgroundColor: AppColors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          label: Text(
                            isStudentSelfPay ? 'Confirm & Submit Rent' : 'Record Payment Receipt',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentDetailsSheet(BuildContext context, PaymentItem item, Color themeColor, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.isPaid ? const Color(0xFFDFF8EB) : const Color(0xFFFFF0D8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                    color: item.isPaid ? AppColors.green : AppColors.orange,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '৳${item.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
              ),
              Center(
                child: Text(
                  'Rent for ${item.month}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.line),
              const SizedBox(height: 12),

              _buildReceiptRow('Receipt No', item.receiptNo),
              _buildReceiptRow('Resident Name', item.studentName),
              _buildReceiptRow('Assigned Room', item.room),
              _buildReceiptRow('Payment Method', item.method),
              if (item.trxId.isNotEmpty) _buildReceiptRow('Transaction ID', item.trxId),
              _buildReceiptRow('Payment Date', item.date),
              _buildReceiptRow('Payment Status', item.isPaid ? 'PAID (Verified)' : 'PENDING (Due)', isHighlight: true, isPaid: item.isPaid),

              const SizedBox(height: 20),
              if (widget.isAdmin) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.isPaid ? AppColors.orange : AppColors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          provider.togglePaymentStatus(item.id);
                          Navigator.pop(ctx);
                        },
                        child: Text(item.isPaid ? 'Mark as DUE' : 'Mark as PAID'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: const BorderSide(color: AppColors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        provider.deletePayment(item.id);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close Receipt'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildReceiptRow(String label, String value, {bool isHighlight = false, bool isPaid = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight
                  ? (isPaid ? AppColors.green : AppColors.orange)
                  : AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navy)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: AppColors.muted),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF1F5F9) : AppColors.inputFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final themeColor = appProvider.themeColor;
    final isAdminMode = widget.isAdmin;

    final sourceList = isAdminMode ? appProvider.payments : appProvider.myPayments;

    final displayPayments = sourceList.where((p) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.studentName.toLowerCase().contains(q) ||
          p.receiptNo.toLowerCase().contains(q) ||
          p.room.toLowerCase().contains(q);
    }).toList();

    double totalCollected = 0;
    double totalDue = 0;
    for (var p in sourceList) {
      if (p.isPaid) {
        totalCollected += p.amount;
      } else {
        totalDue += p.amount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isAdminMode ? 'Payment Management' : 'My Payment Receipts',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: themeColor),
            tooltip: isAdminMode ? 'Record Payment' : 'Pay Rent',
            onPressed: () => _showAddPaymentSheet(context, themeColor, isStudentSelfPay: !isAdminMode),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Card (Collected vs Due)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(fontSize: 11, color: AppColors.muted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '৳${totalCollected.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 36, width: 1, color: AppColors.line),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pending Due',
                              style: TextStyle(fontSize: 11, color: AppColors.muted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${totalDue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search by student name, room, or receipt...',
                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.muted),
                    prefixIcon: Icon(Icons.search, size: 18, color: themeColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16, color: AppColors.muted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Payment List
            Expanded(
              child: RefreshIndicator(
                color: themeColor,
                onRefresh: () => appProvider.fetchPayments(),
                child: displayPayments.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.line),
                                SizedBox(height: 8),
                                Text(
                                  'No payment receipts found',
                                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        itemCount: displayPayments.length,
                        itemBuilder: (context, index) {
                        final item = displayPayments[index];
                        final isPaid = item.isPaid;

                        return InkWell(
                          onTap: () => _showPaymentDetailsSheet(context, item, themeColor, appProvider),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.line),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isPaid ? const Color(0xFFDFF8EB) : const Color(0xFFFFF0D8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                                    color: isPaid ? AppColors.green : AppColors.orange,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.receiptNo,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.navy,
                                            ),
                                          ),
                                          Text(
                                            '৳${item.amount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.studentName} · ${item.room}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.muted),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.month} · via ${item.method}${item.trxId.isNotEmpty ? " · Trx: ${item.trxId}" : ""}',
                                        style: const TextStyle(fontSize: 10, color: AppColors.muted),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // If Admin: toggle status & delete
                                if (isAdminMode) ...[
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      appProvider.togglePaymentStatus(item.id);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPaid
                                            ? AppColors.green.withValues(alpha: 0.1)
                                            : AppColors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isPaid ? 'PAID' : 'DUE',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isPaid ? AppColors.green : AppColors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                                    onPressed: () {
                                      appProvider.deletePayment(item.id);
                                    },
                                  ),
                                ] else ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPaid ? const Color(0xFFDFF8EB) : const Color(0xFFFFF0D8),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isPaid ? 'PAID' : 'DUE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isPaid ? AppColors.green : AppColors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),

            // Bottom Action Bar: Pay Rent for Student / Record Payment for Admin
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () => _showAddPaymentSheet(context, themeColor, isStudentSelfPay: !isAdminMode),
                  icon: Icon(isAdminMode ? Icons.add : Icons.credit_card_rounded, color: Colors.white, size: 20),
                  label: Text(
                    isAdminMode ? 'Record Student Payment' : 'Pay Hostel Rent / Submit Receipt',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
