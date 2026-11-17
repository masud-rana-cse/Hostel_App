import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class ComplainScreen extends StatefulWidget {
  final bool isAdmin;

  const ComplainScreen({super.key, this.isAdmin = true});

  @override
  State<ComplainScreen> createState() => _ComplainScreenState();
}

class _ComplainScreenState extends State<ComplainScreen> {
  int _selectedTab = 0; // 0: All, 1: Pending, 2: Approved, 3: Rejected

  void _showAddComplaintSheet(BuildContext context, Color themeColor) {
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    final roomCtrl = TextEditingController(text: user?.room ?? '204B');
    final descCtrl = TextEditingController();
    String category = 'Plumbing';
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
                          decoration: BoxDecoration(
                            color: AppColors.line,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'File a Complaint / Report Issue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hostel management will attend to your request promptly',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      const Text(
                        'Category',
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
                            value: category,
                            isExpanded: true,
                            items: ['Plumbing', 'Electrical', 'Furniture', 'Cleaning', 'Wi-Fi / Internet', 'Other']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() {
                                  category = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Room Input
                      const Text(
                        'Room Number',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: roomCtrl,
                        style: const TextStyle(fontSize: 12),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Room is required' : null,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'e.g. 204B',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      const Text(
                        'Issue Description',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 12),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please describe the problem' : null,
                        decoration: InputDecoration(
                          hintText: 'Describe what needs fixing or repair...',
                          hintStyle: const TextStyle(fontSize: 11, color: AppColors.muted),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Provider.of<AppProvider>(context, listen: false).addComplaint(
                                description: descCtrl.text.trim(),
                                category: category,
                                room: roomCtrl.text.trim(),
                              );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Complaint submitted successfully! Management notified.'),
                                  backgroundColor: AppColors.green,
                                ),
                              );
                            }
                          },
                          child: const Text('Submit Complaint Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _deleteComplaint(BuildContext context, ComplaintItem complaint) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Complaint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
        content: Text('Delete ticket ${complaint.ticketNo}?', style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<AppProvider>(context, listen: false).deleteComplaint(complaint.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final themeColor = appProvider.themeColor;
    final isAdminMode = widget.isAdmin;

    // Admin sees ALL complaints; Student sees their own complaints
    final complaintSource = isAdminMode ? appProvider.complaints : appProvider.myComplaints;

    final displayComplaints = complaintSource.where((c) {
      if (_selectedTab == 1) return c.isPending;
      if (_selectedTab == 2) return c.isApproved;
      if (_selectedTab == 3) return c.isRejected;
      return true;
    }).toList();

    final pendingCount = complaintSource.where((c) => c.isPending).length;
    final approvedCount = complaintSource.where((c) => c.isApproved).length;
    final rejectedCount = complaintSource.where((c) => c.isRejected).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isAdminMode ? 'Complaints Management' : 'My Complaints',
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
            tooltip: 'File Complaint',
            onPressed: () => _showAddComplaintSheet(context, themeColor),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs: All, Pending, Approved, Rejected
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF5FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildTab(0, 'All (${complaintSource.length})', themeColor),
                    _buildTab(1, 'Pending ($pendingCount)', themeColor),
                    _buildTab(2, 'Approved ($approvedCount)', themeColor),
                    _buildTab(3, 'Rejected ($rejectedCount)', themeColor),
                  ],
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: themeColor,
                onRefresh: () => appProvider.fetchComplaints(),
                child: displayComplaints.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.line),
                                const SizedBox(height: 8),
                                Text(
                                  isAdminMode ? 'No complaints in this category' : 'You have no complaints in this category',
                                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        itemCount: displayComplaints.length,
                        itemBuilder: (context, index) {
                        final item = displayComplaints[index];
                        final isApproved = item.isApproved;
                        final isRejected = item.isRejected;

                        Color statusBgColor = const Color(0xFFFFF0D8);
                        Color statusTextColor = AppColors.orange;
                        String statusLabel = 'PENDING';

                        if (isApproved) {
                          statusBgColor = const Color(0xFFDFF8EB);
                          statusTextColor = AppColors.green;
                          statusLabel = 'APPROVED';
                        } else if (isRejected) {
                          statusBgColor = const Color(0xFFFEE2E2);
                          statusTextColor = AppColors.red;
                          statusLabel = 'REJECTED';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isRejected
                                  ? AppColors.red.withValues(alpha: 0.3)
                                  : isApproved
                                      ? AppColors.green.withValues(alpha: 0.3)
                                      : AppColors.line,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.cardShadow,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.ticketNo,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F8FC),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.line),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.muted),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: statusTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.studentName} · Room ${item.room}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.text,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppColors.line),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.date,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // ADMIN APPROVE & REJECT ACTIONS
                                      if (isAdminMode) ...[
                                        if (!isApproved) ...[
                                          InkWell(
                                            onTap: () {
                                              appProvider.approveComplaint(item.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${item.ticketNo} has been APPROVED!'),
                                                  backgroundColor: AppColors.green,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDFF8EB),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(Icons.check_circle_outline, size: 12, color: AppColors.green),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Approve',
                                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.green),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        if (!isRejected) ...[
                                          InkWell(
                                            onTap: () {
                                              appProvider.rejectComplaint(item.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${item.ticketNo} has been REJECTED.'),
                                                  backgroundColor: AppColors.red,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEE2E2),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(Icons.cancel_outlined, size: 12, color: AppColors.red),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Reject',
                                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        if (isApproved || isRejected) ...[
                                          InkWell(
                                            onTap: () {
                                              appProvider.reopenComplaint(item.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${item.ticketNo} reopened and set to PENDING.'),
                                                  backgroundColor: AppColors.orange,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF0D8),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Reopen',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.orange),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        InkWell(
                                          onTap: () => _deleteComplaint(context, item),
                                          child: const Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                                        ),
                                      ] else ...[
                                        // USER VIEW STATUS LABEL
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusBgColor,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isApproved
                                                ? 'Approved by Admin'
                                                : isRejected
                                                    ? 'Rejected by Admin'
                                                    : 'Under Admin Review',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: statusTextColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ),

            // Bottom Add Complaint Bar for Students
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
                  onPressed: () => _showAddComplaintSheet(context, themeColor),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'File New Complaint Ticket',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, Color themeColor) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.08),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? themeColor : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
