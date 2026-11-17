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
      List<dynamic> res;
      try {
        res = await _supabase
            .from('profiles')
            .select()
            .order('created_at', ascending: false);
      } catch (_) {
        res = await _supabase.from('profiles').select();
      }

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

  Future<bool> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String department,
    required String room,
    required String studentId,
    required String address,
  }) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'name': name,
        'phone': phone,
        'department': department,
        'room': room,
        'student_id': studentId,
        'address': address,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating profile in Supabase: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // 2. STUDENTS ROSTER (Supports both 'students' and 'student' tables)
  // -------------------------------------------------------------
  Future<List<StudentItem>> fetchStudents() async {
    try {
      List<dynamic> res = [];
      try {
        res = await _supabase.from('students').select().order('created_at', ascending: false);
      } catch (_) {
        try {
          res = await _supabase.from('students').select();
        } catch (_) {
          try {
            res = await _supabase.from('student').select().order('created_at', ascending: false);
          } catch (_) {
            try {
              res = await _supabase.from('student').select();
            } catch (_) {
              res = [];
            }
          }
        }
      }
      return res.map((m) => StudentItem.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching students from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertStudent(StudentItem student) async {
    try {
      try {
        await _supabase.from('students').upsert(student.toMap());
        debugPrint('Successfully saved student ${student.name} to students table!');
        return true;
      } catch (e1) {
        // Fallback 1: try 'student' table
        try {
          await _supabase.from('student').upsert(student.toMap());
          debugPrint('Successfully saved student ${student.name} to student table!');
          return true;
        } catch (e2) {
          // Fallback 2: If id is an auto-increment or serial int8, omit 'id'
          final mapWithoutId = Map<String, dynamic>.from(student.toMap())..remove('id');
          try {
            await _supabase.from('students').insert(mapWithoutId);
            return true;
          } catch (_) {
            await _supabase.from('student').insert(mapWithoutId);
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('Error inserting student in Supabase: $e');
      return false;
    }
  }

  Future<bool> updateStudent(StudentItem student) async {
    try {
      try {
        await _supabase.from('students').upsert(student.toMap());
        return true;
      } catch (_) {
        try {
          await _supabase.from('student').upsert(student.toMap());
          return true;
        } catch (_) {
          final map = student.toMap();
          try {
            await _supabase.from('students').update(map).eq('id', student.id);
            return true;
          } catch (_) {
            await _supabase.from('student').update(map).eq('name', student.name);
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating student in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      try {
        await _supabase.from('students').delete().eq('id', id);
      } catch (_) {
        try {
          await _supabase.from('student').delete().eq('id', id);
        } catch (_) {
          // If id is text matching student_id or name
          await _supabase.from('student').delete().eq('student_id', id);
        }
      }
      debugPrint('Successfully deleted student $id from Supabase!');
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
      List<dynamic> res = [];
      try {
        res = await _supabase.from('staff').select().order('name', ascending: true);
      } catch (_) {
        try {
          res = await _supabase.from('staff').select();
        } catch (_) {
          res = [];
        }
      }

      return res.map((m) => StaffMember.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching staff from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertStaff(StaffMember member) async {
    try {
      await _supabase.from('staff').upsert(member.toMap());
      return true;
    } catch (e) {
      debugPrint('Error inserting staff member in Supabase: $e');
      return false;
    }
  }

  Future<bool> updateStaff(StaffMember member) async {
    try {
      await _supabase.from('staff').upsert(member.toMap());
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
      List<dynamic> res = [];
      try {
        res = await _supabase.from('complaints').select().order('created_at', ascending: false);
      } catch (_) {
        try {
          res = await _supabase.from('complaints').select();
        } catch (_) {
          res = [];
        }
      }

      return res.map((m) => ComplaintItem.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching complaints from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertComplaint(ComplaintItem complaint) async {
    try {
      try {
        await _supabase.from('complaints').upsert(complaint.toMap());
        return true;
      } catch (e1) {
        final basicMap = {
          'id': complaint.id,
          'ticket_no': complaint.ticketNo,
          'student_name': complaint.studentName,
          'room': complaint.room,
          'category': complaint.category,
          'description': complaint.description,
          'date': complaint.date,
          'status': complaint.status,
        };
        await _supabase.from('complaints').upsert(basicMap);
        return true;
      }
    } catch (e) {
      debugPrint('Error inserting complaint in Supabase: $e');
      return false;
    }
  }

  Future<bool> updateComplaintStatus(String id, String newStatus) async {
    try {
      await _supabase
          .from('complaints')
          .update({'status': newStatus.toUpperCase()})
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
      List<dynamic> res = [];
      try {
        res = await _supabase.from('payments').select().order('created_at', ascending: false);
      } catch (_) {
        try {
          res = await _supabase.from('payments').select();
        } catch (_) {
          res = [];
        }
      }

      return res.map((m) => PaymentItem.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching payments from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertPayment(PaymentItem payment) async {
    try {
      try {
        await _supabase.from('payments').upsert(payment.toMap());
        return true;
      } catch (e1) {
        final basicMap = {
          'id': payment.id,
          'receipt_no': payment.receiptNo,
          'student_name': payment.studentName,
          'room': payment.room,
          'amount': payment.amount,
          'date': payment.date,
          'is_paid': payment.isPaid,
          'month': payment.month,
          'method': payment.method,
        };
        await _supabase.from('payments').upsert(basicMap);
        return true;
      }
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
