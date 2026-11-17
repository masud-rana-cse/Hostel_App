import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Dedicated Backend Database Service for Supabase PostgreSQL Tables
class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // -------------------------------------------------------------
  // 1. PROFILES & USER ROLES
  // -------------------------------------------------------------
  Future<List<AppUser>> fetchAllProfiles() async {
    try {
      final List<dynamic> res = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return res.map((m) => AppUser.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching profiles from Supabase: $e');
      return [];
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await _supabase
          .from('profiles')
          .update({'role': newRole})
          .eq('id', userId);
      return true;
    } catch (e) {
      debugPrint('Error updating user role in Supabase: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // 2. STUDENTS ROSTER
  // -------------------------------------------------------------
  Future<List<StudentItem>> fetchStudents() async {
    try {
      final List<dynamic> res = await _supabase
          .from('students')
          .select()
          .order('joined_date', ascending: false);

      return res.map((m) => StudentItem.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching students from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertStudent(StudentItem student) async {
    try {
      await _supabase.from('students').insert(student.toMap());
      return true;
    } catch (e) {
      debugPrint('Error inserting student in Supabase: $e');
      return false;
    }
  }

  Future<bool> updateStudent(StudentItem student) async {
    try {
      await _supabase
          .from('students')
          .update(student.toMap())
          .eq('id', student.id);
      return true;
    } catch (e) {
      debugPrint('Error updating student in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      await _supabase.from('students').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting student from Supabase: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // 3. STAFF MEMBERS
  // -------------------------------------------------------------
  Future<List<StaffMember>> fetchStaff() async {
    try {
      final List<dynamic> res = await _supabase
          .from('staff')
          .select()
          .order('name', ascending: true);

      return res.map((m) => StaffMember.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching staff from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertStaff(StaffMember member) async {
    try {
      await _supabase.from('staff').insert(member.toMap());
      return true;
    } catch (e) {
      debugPrint('Error inserting staff member in Supabase: $e');
      return false;
    }
  }

  Future<bool> updateStaff(StaffMember member) async {
    try {
      await _supabase
          .from('staff')
          .update(member.toMap())
          .eq('id', member.id);
      return true;
    } catch (e) {
      debugPrint('Error updating staff member in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteStaff(String id) async {
    try {
      await _supabase.from('staff').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting staff member from Supabase: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // 4. COMPLAINTS TICKETS
  // -------------------------------------------------------------
  Future<List<ComplaintItem>> fetchComplaints() async {
    try {
      final List<dynamic> res = await _supabase
          .from('complaints')
          .select()
          .order('created_at', ascending: false);

      return res.map((m) => ComplaintItem.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching complaints from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertComplaint(ComplaintItem complaint) async {
    try {
      await _supabase.from('complaints').insert(complaint.toMap());
      return true;
    } catch (e) {
      debugPrint('Error inserting complaint in Supabase: $e');
      return false;
    }
  }

  Future<bool> updateComplaintStatus(String id, String newStatus) async {
    try {
      await _supabase
          .from('complaints')
          .update({'status': newStatus})
          .eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error updating complaint status in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteComplaint(String id) async {
    try {
      await _supabase.from('complaints').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting complaint from Supabase: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // 5. PAYMENTS & RECEIPTS
  // -------------------------------------------------------------
  Future<List<PaymentItem>> fetchPayments() async {
    try {
      final List<dynamic> res = await _supabase
          .from('payments')
          .select()
          .order('created_at', ascending: false);

      return res.map((m) => PaymentItem.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching payments from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertPayment(PaymentItem payment) async {
    try {
      await _supabase.from('payments').insert(payment.toMap());
      return true;
    } catch (e) {
      debugPrint('Error inserting payment in Supabase: $e');
      return false;
    }
  }

  Future<bool> updatePaymentStatus(String id, bool isPaid) async {
    try {
      await _supabase
          .from('payments')
          .update({'is_paid': isPaid})
          .eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error updating payment status in Supabase: $e');
      return false;
    }
  }

  Future<bool> deletePayment(String id) async {
    try {
      await _supabase.from('payments').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting payment from Supabase: $e');
      return false;
    }
  }
}
