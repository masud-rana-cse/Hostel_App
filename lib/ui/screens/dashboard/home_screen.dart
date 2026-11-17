import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;
  final bool isAdmin;

  const HomeScreen({super.key, this.onTabSelected, this.isAdmin = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showNotificationsSheet(AppProvider provider) {
    final pendingComplaints = provider.complaints.where((c) => c.status == 'PENDING').length;
    final paidCount = provider.payments.where((p) => p.isPaid).length;
    final dueCount = provider.payments.where((p) => !p.isPaid).length;
    final userCount = provider.allUsers.length;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(pendingComplaints > 0 ? 1 : 0) + (dueCount > 0 ? 1 : 0) + 1} New',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (pendingComplaints > 0)
                _buildNotificationItem(
                  color: AppColors.red,
                  title: 'Active Complaints Pending',
                  subtitle: '$pendingComplaints resident complaint ticket(s) require action',
                  time: 'Active',
                ),
              if (dueCount > 0)
                _buildNotificationItem(
                  color: AppColors.orange,
                  title: 'Pending Invoices',
                  subtitle: '$dueCount unpaid hostel payment(s) recorded in Supabase',
                  time: 'Attention',
                ),
              _buildNotificationItem(
                color: AppColors.green,
                title: 'Supabase Cloud Sync',
                subtitle: '$paidCount paid receipt(s) & $userCount registered user account(s) online',
                time: 'Live',
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showRoomDetailsSheet(String room, Color themeColor, AppProvider provider) {
    final roommates = provider.students
        .where((s) => s.room.trim().toLowerCase() == room.trim().toLowerCase())
        .map((s) => s.name)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                'Room $room Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 14),
              _buildRoomDetailItem('Assigned Room', room.isNotEmpty ? room : 'Unassigned'),
              _buildRoomDetailItem(
                'Current Residents',
                roommates.isNotEmpty ? roommates.join(', ') : 'No roommates assigned yet',
              ),
              _buildRoomDetailItem('Facilities', 'Wi-Fi, 24/7 IPS Power, Daily Housekeeping'),
              _buildRoomDetailItem('Standard Rent', '৳3,000 / Month'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserDetailsSheet(AppUser u, Color themeColor, AppProvider provider) {
    final isAdminUser = u.isAdmin;
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isAdminUser
                        ? themeColor.withValues(alpha: 0.15)
                        : const Color(0xFFEAF3FF),
                    child: Text(
                      u.initials,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isAdminUser ? themeColor : AppColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          u.email,
                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdminUser ? const Color(0xFFEDE9FE) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAdminUser ? 'ADMIN' : 'STUDENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAdminUser ? const Color(0xFF6D28D9) : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.line),
              _buildRoomDetailItem('Student ID', u.studentId),
              _buildRoomDetailItem('Assigned Room', u.room),
              _buildRoomDetailItem('Department', u.department),
              _buildRoomDetailItem('Phone Number', u.phone),
              _buildRoomDetailItem('Address', u.address),
              _buildRoomDetailItem('Joined Date', u.joinedDate),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.muted,
                        side: const BorderSide(color: AppColors.line),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdminUser ? const Color(0xFFFEE2E2) : themeColor,
                        foregroundColor: isAdminUser ? AppColors.red : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        provider.toggleAdminPermission(u.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${u.name} role updated to ${!isAdminUser ? "Admin" : "Student"}!',
                            ),
                            backgroundColor: !isAdminUser ? AppColors.green : AppColors.orange,
                          ),
                        );
                      },
                      child: Text(isAdminUser ? 'Revoke Admin' : 'Make Admin'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicPaymentChart({
    required List<PaymentItem> payments,
    required Color themeColor,
    required double height,
    required String emptyMessage,
  }) {
    final paidList = payments.where((p) => p.isPaid).toList();
    if (paidList.isEmpty) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(14),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_rounded, size: 32, color: AppColors.muted.withValues(alpha: 0.5)),
              const SizedBox(height: 6),
              Text(
                emptyMessage,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Group paid amounts by month
    final Map<String, double> monthlySums = {};
    for (final p in paidList) {
      final rawMonth = p.month.trim();
      final parts = rawMonth.split(' ');
      String shortMonth = parts.first;
      if (shortMonth.length > 3) {
        shortMonth = shortMonth.substring(0, 3);
      }
      monthlySums[shortMonth] = (monthlySums[shortMonth] ?? 0.0) + p.amount;
    }

    double maxVal = 0.0;
    for (final v in monthlySums.values) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal <= 0) maxVal = 1.0;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FBFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthlySums.entries.map((entry) {
          final heightFactor = (entry.value / maxVal).clamp(0.2, 1.0);
          return _BarItem(
            heightFactor: heightFactor,
            label: entry.key,
            amountText: '৳${entry.value.toStringAsFixed(0)}',
            themeColor: themeColor,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoomDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;
    final themeColor = appProvider.themeColor;
    final isAdminMode = widget.isAdmin;

    final userName = user?.name ?? (isAdminMode ? 'Hostel Administrator' : 'Student Resident');
    final userSubtitle = isAdminMode
        ? 'Admin Portal · Full System Access'
        : 'Resident · ${(user != null && user.room.isNotEmpty) ? user.room : "Room Unassigned"}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.line, width: 1.0),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: themeColor.withValues(alpha: 0.15),
                      child: Text(
                        user?.initials ?? (isAdminMode ? 'AD' : 'MR'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          userSubtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.navy,
                        size: 22,
                      ),
                      onPressed: () => _showNotificationsSheet(appProvider),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: themeColor,
          onRefresh: () => appProvider.fetchAllDataFromSupabase(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: isAdminMode
                ? _buildAdminDashboard(appProvider, themeColor)
                : _buildStudentDashboard(appProvider, themeColor),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ADMIN DASHBOARD
  // ==========================================
  Widget _buildAdminDashboard(AppProvider provider, Color themeColor) {
    final totalStudents = provider.students.length;
    final totalStaff = provider.staff.length;
    final totalUsers = provider.allUsers.length;
    final pendingComplaints = provider.complaints.where((c) => c.status == 'PENDING').length;

    double totalPaid = 0;
    double totalDue = 0;
    for (var p in provider.payments) {
      if (p.isPaid) {
        totalPaid += p.amount;
      } else {
        totalDue += p.amount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4-Grid Statistics
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
              title: 'Total Students',
              value: '$totalStudents Students',
              valueColor: AppColors.navy,
              icon: Icons.school_outlined,
              iconColor: themeColor,
              onTap: () => widget.onTabSelected?.call(1),
            ),
            _buildStatCard(
              title: 'Total Staff',
              value: '$totalStaff Active',
              valueColor: AppColors.navy,
              icon: Icons.badge_outlined,
              iconColor: AppColors.green,
              onTap: () => widget.onTabSelected?.call(2),
            ),
            _buildStatCard(
              title: 'Pending Dues',
              value: '৳${totalDue.toStringAsFixed(0)}',
              valueColor: AppColors.orange,
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppColors.orange,
              onTap: () => widget.onTabSelected?.call(3),
            ),
            _buildStatCard(
              title: 'Active Complaints',
              value: '$pendingComplaints Pending',
              valueColor: AppColors.red,
              icon: Icons.report_problem_outlined,
              iconColor: AppColors.red,
              onTap: () => widget.onTabSelected?.call(4),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Quick Action Shortcuts
        Row(
          children: [
            Expanded(
              child: _buildQuickButton(
                icon: Icons.person_add_alt_1_outlined,
                label: 'Students (${provider.students.length})',
                themeColor: themeColor,
                onTap: () => widget.onTabSelected?.call(1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                icon: Icons.badge_outlined,
                label: 'Staff (${provider.staff.length})',
                themeColor: themeColor,
                onTap: () => widget.onTabSelected?.call(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                icon: Icons.credit_card_outlined,
                label: 'Payments',
                themeColor: themeColor,
                onTap: () => widget.onTabSelected?.call(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 1. ALL REGISTERED USERS & PERMISSION MANAGEMENT (Requested by user)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.manage_accounts_rounded, size: 18, color: themeColor),
                const SizedBox(width: 6),
                const Text(
                  'All Registered Users',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$totalUsers Users',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'View all logged-in accounts and toggle Admin permission',
          style: TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: provider.allUsers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'No registered users found in Supabase yet.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ),
                )
              : ListView.separated(
            padding: const EdgeInsets.all(10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.allUsers.length,
            separatorBuilder: (context, index) => const Divider(height: 14, color: AppColors.line),
            itemBuilder: (context, index) {
              final u = provider.allUsers[index];
              final isAdminUser = u.isAdmin;

              return InkWell(
                onTap: () => _showUserDetailsSheet(u, themeColor, provider),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isAdminUser
                            ? themeColor.withValues(alpha: 0.15)
                            : const Color(0xFFEAF3FF),
                        child: Text(
                          u.initials,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isAdminUser ? themeColor : AppColors.navy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    u.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navy,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAdminUser
                                        ? const Color(0xFFEDE9FE)
                                        : const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAdminUser ? 'ADMIN' : 'STUDENT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isAdminUser
                                          ? const Color(0xFF6D28D9)
                                          : const Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${u.email}  ·  ID: ${u.studentId}  ·  Room: ${u.room}',
                              style: const TextStyle(fontSize: 10, color: AppColors.muted),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Dept: ${u.department}  ·  ${u.phone}',
                              style: const TextStyle(fontSize: 10, color: AppColors.muted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Permission Toggle Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAdminUser ? const Color(0xFFFEE2E2) : themeColor,
                          foregroundColor: isAdminUser ? AppColors.red : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          provider.toggleAdminPermission(u.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${u.name} is now ${!isAdminUser ? "granted Admin access" : "set to Student access"}!',
                              ),
                              backgroundColor: !isAdminUser ? AppColors.green : AppColors.orange,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          isAdminUser ? 'Revoke Admin' : 'Make Admin',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),

        // Monthly Payment Chart Section (100% Real Supabase Data)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Monthly Collections Chart',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            Text(
              'Collected: ৳${totalPaid.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDynamicPaymentChart(
          payments: provider.payments,
          themeColor: themeColor,
          height: 140,
          emptyMessage: 'No collection history recorded in Supabase yet',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==========================================
  // STUDENT / USER DASHBOARD
  // ==========================================
  Widget _buildStudentDashboard(AppProvider provider, Color themeColor) {
    final user = provider.currentUser;
    final myRoom = (user != null && user.room.isNotEmpty) ? user.room : 'Unassigned';
    final myComplaints = provider.myComplaints;
    final pendingCount = myComplaints.where((c) => c.status == 'PENDING').length;
    final resolvedCount = myComplaints.where((c) => c.status == 'RESOLVED').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [themeColor, themeColor.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '▣ Room $myRoom',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bed: A · 2nd Floor · Active Resident',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFDCECFF),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.navy,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showRoomDetailsSheet(myRoom, themeColor, provider),
                child: const Text(
                  'Room Details',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2 Stats Cards (100% Real Supabase Data)
        Row(
          children: [
            Expanded(
              child: _buildStudentStatCard(
                label: 'Monthly Rent',
                value: provider.myPayments.isNotEmpty
                    ? '৳${provider.myPayments.first.amount.toStringAsFixed(0)}'
                    : '৳3,000',
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _buildStudentStatCard(
                label: 'Last Payment',
                value: () {
                  final paid = provider.myPayments.where((p) => p.isPaid).toList();
                  return paid.isNotEmpty
                      ? '৳${paid.last.amount.toStringAsFixed(0)} (Paid)'
                      : 'No payments yet';
                }(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // My Complaints Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.report_problem_outlined, color: AppColors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Complaints Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$pendingCount Ticket Pending · $resolvedCount Resolved',
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => widget.onTabSelected?.call(4),
                child: const Text('File Complaint', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Student Payment History Chart (100% Real Supabase Data)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Payment History',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTabSelected?.call(3),
              child: Text(
                'View All Receipts',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDynamicPaymentChart(
          payments: provider.myPayments,
          themeColor: themeColor,
          height: 120,
          emptyMessage: 'No payment records found for your account yet',
        ),
        const SizedBox(height: 18),

        // Staff Helpline Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: themeColor.withValues(alpha: 0.15),
                child: Icon(Icons.support_agent_rounded, size: 20, color: themeColor),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Hostel Staff Assistance?',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy),
                    ),
                    Text(
                      'Warden & emergency security on duty 24/7',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => widget.onTabSelected?.call(2),
                icon: const Icon(Icons.call, size: 12),
                label: const Text('Call Staff', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 14, color: iconColor),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required Color themeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: themeColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentStatCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final double heightFactor;
  final String label;
  final String? amountText;
  final Color themeColor;

  const _BarItem({
    required this.heightFactor,
    required this.label,
    this.amountText,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (amountText != null) ...[
          Text(
            amountText!,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          width: 22,
          height: 65 * heightFactor,
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.muted),
        ),
      ],
    );
  }
}
