import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../backend/backend.dart';
import '../models/models.dart';
import '../ui/theme/app_theme.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  AppUser? _currentUser;
  Color _themeColor = AppColors.blue;
  bool _isLoadingData = false;

  // Real Database Collections from Supabase
  final List<AppUser> _users = [];
  final List<StudentItem> _students = [];
  final List<StaffMember> _staff = [];
  final List<ComplaintItem> _complaints = [];
  final List<PaymentItem> _payments = [];

  // Preset Theme Colors
  static const List<Map<String, dynamic>> themePresets = [
    {'name': 'Ocean Blue', 'color': Color(0xFF0868DF)},
    {'name': 'Royal Indigo', 'color': Color(0xFF4F46E5)},
    {'name': 'Emerald Green', 'color': Color(0xFF059669)},
    {'name': 'Crimson Red', 'color': Color(0xFFDC2626)},
    {'name': 'Midnight Purple', 'color': Color(0xFF7C3AED)},
    {'name': 'Sunset Amber', 'color': Color(0xFFEA580C)},
  ];

  AppProvider() {
    _initSupabaseSession();
    _authService.ensureAdminAccountExists();
  }

  // -------------------------------------------------------------
  // INITIALIZATION & SESSION MANAGEMENT
  // -------------------------------------------------------------
  void _initSupabaseSession() {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _loadUserAndFetchData(user);
      }

      _authService.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          _loadUserAndFetchData(session.user);
        } else if (event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          _clearLocalData();
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Notice during Supabase session initialization: $e');
    }
  }

  Future<void> _loadUserAndFetchData(User user) async {
    _currentUser = await _authService.fetchUserProfile(user);
    notifyListeners();
    await fetchAllDataFromSupabase();
  }

  void _clearLocalData() {
    _users.clear();
    _students.clear();
    _staff.clear();
    _complaints.clear();
    _payments.clear();
  }

  // -------------------------------------------------------------
  // GETTERS (100% Real Supabase Data)
  // -------------------------------------------------------------
  AppUser? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  Color get themeColor => _themeColor;
  bool get isLoadingData => _isLoadingData;

  List<AppUser> get allUsers {
    if (_users.isEmpty && _currentUser != null) {
      return [_currentUser!];
    }
    return List.unmodifiable(_users);
  }

  List<StudentItem> get students => List.unmodifiable(_students);
  List<StaffMember> get staff => List.unmodifiable(_staff);
  List<ComplaintItem> get complaints => List.unmodifiable(_complaints);
  List<PaymentItem> get payments => List.unmodifiable(_payments);

  // Filtered Complaints for current student resident
  List<ComplaintItem> get myComplaints {
    if (_currentUser == null) return [];
    return _complaints.where((c) {
      return c.userId == _currentUser!.id ||
          (c.studentName.isNotEmpty &&
              c.studentName.toLowerCase() == _currentUser!.name.toLowerCase()) ||
          (c.room.isNotEmpty &&
              c.room.toLowerCase() == _currentUser!.room.toLowerCase());
    }).toList();
  }

  // Filtered Payments for current student resident
  List<PaymentItem> get myPayments {
    if (_currentUser == null) return [];
    return _payments.where((p) {
      return (p.userId.isNotEmpty && p.userId == _currentUser!.id) ||
          (p.studentName.isNotEmpty &&
              p.studentName.toLowerCase() == _currentUser!.name.toLowerCase()) ||
          (p.room.isNotEmpty &&
              p.room.toLowerCase().replaceAll('room', '').trim() ==
                  _currentUser!.room.toLowerCase().replaceAll('room', '').trim());
    }).toList();
  }

  // -------------------------------------------------------------
  // THEME COLOR SETTER
  // -------------------------------------------------------------
  void setThemeColor(Color color) {
    _themeColor = color;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // DATA FETCHING FROM SUPABASE POSTGRESQL TABLES
  // -------------------------------------------------------------
  Future<void> fetchAllDataFromSupabase() async {
    _isLoadingData = true;
    notifyListeners();

    try {
      await fetchProfiles();
      await Future.wait([
        fetchStudents(),
        fetchStaff(),
        fetchComplaints(),
        fetchPayments(),
      ]);
    } catch (e) {
      debugPrint('Notice fetching Supabase database tables: $e');
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfiles() async {
    final list = await _dbService.fetchAllProfiles();
    _users.clear();
    _users.addAll(list);
    notifyListeners();
  }

  Future<void> fetchStudents() async {
    final list = await _dbService.fetchStudents();
    _students.clear();
    _students.addAll(list);

    // Synchronize any registered student accounts from profiles into the students list
    for (final u in _users) {
      if (!u.isAdmin && !_students.any((s) => s.id == u.id || (s.studentId.isNotEmpty && s.studentId == u.studentId))) {
        final newStudent = StudentItem(
          id: u.id,
          name: u.name,
          studentId: u.studentId.isNotEmpty ? u.studentId : 'STD-000',
          room: u.room.isNotEmpty ? u.room : '101A',
          phone: u.phone.isNotEmpty ? u.phone : '01700000000',
          department: u.department.isNotEmpty ? u.department : 'CSE',
          joinedDate: u.joinedDate.isNotEmpty ? u.joinedDate : 'Recently',
        );
        _students.add(newStudent);
        _dbService.insertStudent(newStudent);
      }
    }
    notifyListeners();
  }

  Future<void> fetchStaff() async {
    final list = await _dbService.fetchStaff();
    if (list.isNotEmpty) {
      _staff.clear();
      _staff.addAll(list);
    }
    notifyListeners();
  }

  Future<void> fetchComplaints() async {
    final list = await _dbService.fetchComplaints();
    if (list.isNotEmpty) {
      _complaints.clear();
      _complaints.addAll(list);
    }
    notifyListeners();
  }

  Future<void> fetchPayments() async {
    final list = await _dbService.fetchPayments();
    if (list.isNotEmpty) {
      _payments.clear();
      _payments.addAll(list);
    }
    notifyListeners();
  }

  // -------------------------------------------------------------
  // AUTHENTICATION OPERATIONS (100% Real Supabase Auth)
  // -------------------------------------------------------------
  Future<(bool, String)> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || cleanPass.isEmpty) {
      return (false, 'Please enter both email and password.');
    }

    _isLoadingData = true;
    notifyListeners();

    try {
      final (success, message) = await _authService.signInWithPassword(cleanEmail, cleanPass);

      if (success) {
        final user = _authService.currentUser;
        if (user != null) {
          await _loadUserAndFetchData(user);
        }
        return (true, 'Success');
      }

      return (false, message);
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<(bool, String)> signUp({
    required String name,
    required String email,
    required String phone,
    required String studentId,
    required String role,
    required String password,
    String department = 'CSE',
    String room = '101A',
  }) async {
    _isLoadingData = true;
    notifyListeners();

    try {
      final (success, message) = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        studentId: studentId,
        role: role,
        department: department,
        room: room,
      );

      if (success && _authService.currentUser != null) {
        await _loadUserAndFetchData(_authService.currentUser!);
      } else {
        await fetchAllDataFromSupabase();
      }

      return (success, message);
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<(bool, String)> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<(bool, String)> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  Future<bool> changePassword(String newPassword) async {
    return await _authService.changePassword(newPassword);
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _clearLocalData();
    notifyListeners();
  }

  // -------------------------------------------------------------
  // USER PROFILE & ADMIN PERMISSIONS
  // -------------------------------------------------------------
  Future<void> updateCurrentUserProfile({
    required String name,
    required String phone,
    required String department,
    required String room,
    required String address,
    required String studentId,
  }) async {
    if (_currentUser == null) return;

    _currentUser!.name = name;
    _currentUser!.phone = phone;
    _currentUser!.department = department;
    _currentUser!.room = room;
    _currentUser!.address = address;
    _currentUser!.studentId = studentId;

    final uIndex = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (uIndex != -1) {
      _users[uIndex] = _currentUser!;
    }

    notifyListeners();

    await _authService.updateProfile(
      userId: _currentUser!.id,
      name: name,
      phone: phone,
      department: department,
      room: room,
      address: address,
      studentId: studentId,
    );
  }

  Future<void> toggleAdminPermission(String userId) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _users[index];
      final newRole = (user.role.toLowerCase() == 'admin') ? 'student' : 'admin';
      user.role = newRole;

      if (_currentUser?.id == userId) {
        _currentUser!.role = newRole;
      }

      notifyListeners();
      await _dbService.updateUserRole(userId, newRole);
    }
  }

  // -------------------------------------------------------------
  // STUDENTS CRUD OPERATIONS (Real Supabase Backend)
  // -------------------------------------------------------------
  Future<void> addStudent(StudentItem student) async {
    _students.insert(0, student);
    notifyListeners();
    final ok = await _dbService.insertStudent(student);
    if (ok) {
      await fetchStudents();
    }
  }

  Future<void> updateStudent(StudentItem updatedStudent) async {
    final index = _students.indexWhere((s) => s.id == updatedStudent.id);
    if (index != -1) {
      _students[index] = updatedStudent;
      notifyListeners();
    }
    await _dbService.updateStudent(updatedStudent);

    // Also update profiles table if student has a registered account
    final pIndex = _users.indexWhere((u) =>
        u.id == updatedStudent.id ||
        (u.studentId.isNotEmpty && u.studentId == updatedStudent.studentId));
    if (pIndex != -1) {
      final user = _users[pIndex];
      user.name = updatedStudent.name;
      user.room = updatedStudent.room;
      user.phone = updatedStudent.phone;
      user.department = updatedStudent.department;
      user.studentId = updatedStudent.studentId;
      await _dbService.updateProfile(
        userId: user.id,
        name: user.name,
        phone: user.phone,
        department: user.department,
        room: user.room,
        studentId: user.studentId,
        address: user.address,
      );
    }
    await fetchStudents();
  }

  Future<void> deleteStudent(String id) async {
    _students.removeWhere((s) => s.id == id);
    notifyListeners();
    final ok = await _dbService.deleteStudent(id);
    if (ok) {
      await fetchStudents();
    }
  }

  // -------------------------------------------------------------
  // STAFF CRUD OPERATIONS (Real Supabase Backend)
  // -------------------------------------------------------------
  Future<void> addStaff(StaffMember member) async {
    _staff.insert(0, member);
    notifyListeners();
    await _dbService.insertStaff(member);
    await fetchStaff();
  }

  Future<void> updateStaff(StaffMember updatedMember) async {
    final index = _staff.indexWhere((s) => s.id == updatedMember.id);
    if (index != -1) {
      _staff[index] = updatedMember;
      notifyListeners();
    }
    await _dbService.updateStaff(updatedMember);
    await fetchStaff();
  }

  Future<void> deleteStaff(String id) async {
    _staff.removeWhere((s) => s.id == id);
    notifyListeners();
    await _dbService.deleteStaff(id);
    await fetchStaff();
  }

  // -------------------------------------------------------------
  // COMPLAINTS CRUD OPERATIONS (Real Supabase Backend)
  // -------------------------------------------------------------
  Future<void> addComplaint({
    required String description,
    required String category,
    required String room,
  }) async {
    final studentName = _currentUser?.name ?? 'Resident';
    final userId = _currentUser?.id ?? '';
    final newComplaint = ComplaintItem(
      id: 'cmp_${DateTime.now().millisecondsSinceEpoch}',
      ticketNo: 'Ticket #CMP-${100 + _complaints.length + 1}',
      userId: userId,
      studentName: studentName,
      room: room.isNotEmpty ? room : (_currentUser?.room ?? 'Room 101A'),
      category: category,
      description: description,
      date: 'Just now',
      status: 'PENDING',
    );

    _complaints.insert(0, newComplaint);
    notifyListeners();
    await _dbService.insertComplaint(newComplaint);
    await fetchComplaints();
  }

  Future<void> updateComplaintStatus(String id, String newStatus) async {
    final cleanStatus = newStatus.trim().toUpperCase();
    final index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      _complaints[index].status = cleanStatus;
      notifyListeners();
      await _dbService.updateComplaintStatus(id, cleanStatus);
      await fetchComplaints();
    }
  }

  Future<void> approveComplaint(String id) async {
    await updateComplaintStatus(id, 'APPROVED');
  }

  Future<void> rejectComplaint(String id) async {
    await updateComplaintStatus(id, 'REJECTED');
  }

  Future<void> reopenComplaint(String id) async {
    await updateComplaintStatus(id, 'PENDING');
  }

  Future<void> toggleComplaintStatus(String id) async {
    final index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      final current = _complaints[index];
      final newStatus = current.isPending ? 'APPROVED' : 'PENDING';
      current.status = newStatus;
      notifyListeners();
      await _dbService.updateComplaintStatus(id, newStatus);
      await fetchComplaints();
    }
  }

  Future<void> deleteComplaint(String id) async {
    _complaints.removeWhere((c) => c.id == id);
    notifyListeners();
    await _dbService.deleteComplaint(id);
    await fetchComplaints();
  }

  // -------------------------------------------------------------
  // PAYMENTS CRUD OPERATIONS (Real Supabase Backend)
  // -------------------------------------------------------------
  Future<void> addPayment(PaymentItem payment) async {
    _payments.insert(0, payment);
    notifyListeners();
    await _dbService.insertPayment(payment);
    await fetchPayments();
  }

  Future<void> togglePaymentStatus(String id) async {
    final index = _payments.indexWhere((p) => p.id == id);
    if (index != -1) {
      final newStatus = !_payments[index].isPaid;
      _payments[index].isPaid = newStatus;
      notifyListeners();
      await _dbService.updatePaymentStatus(id, newStatus);
      await fetchPayments();
    }
  }

  Future<void> deletePayment(String id) async {
    _payments.removeWhere((p) => p.id == id);
    notifyListeners();
    await _dbService.deletePayment(id);
    await fetchPayments();
  }
}
