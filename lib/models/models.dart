class AppUser {
  final String id;
  String name;
  String email;
  String phone;
  String studentId;
  String role; // 'admin' or 'student'
  String department;
  String room;
  String address;
  String guardian;
  String joinedDate;
  String password;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.studentId,
    required this.role,
    this.department = ' ',
    this.room = ' ',
    this.address = ' ',
    this.guardian = ' ',
    this.joinedDate = ' ',
    this.password = ' ',
  });

  bool get isAdmin => role.toLowerCase() == 'admin' || email.toLowerCase().contains('admin');

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final String email = map['email']?.toString() ?? '';
    final String rawRole = map['role']?.toString().toLowerCase() ?? '';
    final String role = (email.toLowerCase().contains('admin') || rawRole == 'admin') ? 'admin' : 'student';

    return AppUser(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? (email.contains('@') ? email.split('@').first : 'Hostel Administrator'),
      email: email,
      phone: map['phone']?.toString() ?? '01700000000',
      studentId: (map['student_id'] ?? map['studentId'] ?? 'ADM-001').toString(),
      role: role,
      department: map['department']?.toString() ?? 'Hostel Administration',
      room: map['room']?.toString() ?? 'Office 101',
      address: map['address']?.toString() ?? 'Sector 9, Uttara, Dhaka',
      guardian: map['guardian']?.toString() ?? 'Board of Governors',
      joinedDate: (map['joined_date'] ?? map['joinedDate'] ?? 'Jan 01, 2023').toString(),
      password: 'password123',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'student_id': studentId,
      'role': role,
      'department': department,
      'room': room,
      'address': address,
      'guardian': guardian,
      'joined_date': joinedDate,
    };
  }

  factory AppUser.fromSupabase(dynamic user, [Map<String, dynamic>? profileData]) {
    final Map<String, dynamic> meta = (user.userMetadata is Map) ? Map<String, dynamic>.from(user.userMetadata) : {};
    final String email = user.email ?? profileData?['email'] ?? '';
    final String rawRole = (profileData?['role'] ?? meta['role'] ?? '').toString().toLowerCase();
    final String role = (email.toLowerCase().contains('admin') || rawRole == 'admin') ? 'admin' : 'student';
    final String name = (profileData?['name'] ?? meta['name'] ?? (email.contains('@') ? email.split('@').first : 'Hostel Administrator')).toString();
    final String phone = (profileData?['phone'] ?? meta['phone'] ?? '01700000000').toString();
    final String rawId = user.id.toString();
    final String studentId = (profileData?['student_id'] ?? meta['student_id'] ?? (role == 'admin' ? 'ADM-001' : 'STD-100')).toString();
    final String department = (profileData?['department'] ?? meta['department'] ?? (role == 'admin' ? 'Hostel Administration' : 'CSE')).toString();
    final String room = (profileData?['room'] ?? meta['room'] ?? (role == 'admin' ? 'Office 101' : '101A')).toString();
    final String address = (profileData?['address'] ?? meta['address'] ?? 'Sector 9, Uttara, Dhaka').toString();
    final String guardian = (profileData?['guardian'] ?? meta['guardian'] ?? 'Hostel Board').toString();
    final String joinedDate = (profileData?['joined_date'] ?? meta['joined_date'] ?? 'Jan 01, 2023').toString();

    return AppUser(
      id: rawId,
      name: name,
      email: email,
      phone: phone,
      studentId: studentId,
      role: role,
      department: department,
      room: room,
      address: address,
      guardian: guardian,
      joinedDate: joinedDate,
      password: 'password123',
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'HA';
  }
}

class StudentItem {
  final String id;
  String name;
  String studentId;
  String room;
  String phone;
  String department;
  String joinedDate;

  StudentItem({
    required this.id,
    required this.name,
    required this.studentId,
    required this.room,
    this.phone = '01712345678',
    this.department = 'CSE',
    this.joinedDate = 'Jan 15, 2024',
  });

  factory StudentItem.fromMap(Map<String, dynamic> map) {
    return StudentItem(
      id: map['id']?.toString() ?? '',
      name: (map['name'] ?? map['full_name'] ?? map['student_name'] ?? '').toString(),
      studentId: (map['student_id'] ?? map['studentId'] ?? map['roll'] ?? '').toString(),
      room: (map['room'] ?? map['room_no'] ?? map['roomNumber'] ?? '').toString(),
      phone: (map['phone'] ?? map['mobile'] ?? map['phone_number'] ?? '01712345678').toString(),
      department: (map['department'] ?? map['dept'] ?? 'CSE').toString(),
      joinedDate: (map['joined_date'] ?? map['joinedDate'] ?? 'Apr 2025').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
      'room': room,
      'phone': phone,
      'department': department,
      'joined_date': joinedDate,
    };
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'ST';
  }
}

class StaffMember {
  final String id;
  String name;
  String role;
  String shift;
  String salary;
  String phone;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.shift,
    required this.salary,
    required this.phone,
  });

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    return StaffMember(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Staff',
      shift: map['shift']?.toString() ?? 'Day',
      salary: map['salary']?.toString() ?? '৳30,000/mo',
      phone: map['phone']?.toString() ?? '01700000000',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'shift': shift,
      'salary': salary,
      'phone': phone,
    };
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'ST';
  }
}

class ComplaintItem {
  final String id;
  final String ticketNo;
  final String userId;
  String studentName;
  String room;
  String category;
  String description;
  String date;
  String status; // 'PENDING', 'APPROVED', 'REJECTED'

  ComplaintItem({
    required this.id,
    required this.ticketNo,
    this.userId = '',
    required this.studentName,
    required this.room,
    this.category = 'General',
    required this.description,
    required this.date,
    required this.status,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isApproved => status.toUpperCase() == 'APPROVED' || status.toUpperCase() == 'RESOLVED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  factory ComplaintItem.fromMap(Map<String, dynamic> map) {
    return ComplaintItem(
      id: map['id']?.toString() ?? '',
      ticketNo: (map['ticket_no'] ?? map['ticketNo'] ?? 'Ticket #CMP-000').toString(),
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      studentName: (map['student_name'] ?? map['studentName'] ?? 'Resident').toString(),
      room: map['room']?.toString() ?? 'Room 101A',
      category: map['category']?.toString() ?? 'General',
      description: map['description']?.toString() ?? '',
      date: map['date']?.toString() ?? 'Recently',
      status: (map['status']?.toString() ?? 'PENDING').toUpperCase(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_no': ticketNo,
      'user_id': userId,
      'student_name': studentName,
      'room': room,
      'category': category,
      'description': description,
      'date': date,
      'status': status,
    };
  }
}

class PaymentItem {
  final String id;
  final String receiptNo;
  final String userId;
  String studentName;
  String room;
  double amount;
  String date;
  bool isPaid;
  String month;
  String method;
  String trxId;

  PaymentItem({
    required this.id,
    required this.receiptNo,
    this.userId = '',
    required this.studentName,
    required this.room,
    required this.amount,
    required this.date,
    required this.isPaid,
    this.month = 'April 2025',
    this.method = 'bKash',
    this.trxId = '',
  });

  factory PaymentItem.fromMap(Map<String, dynamic> map) {
    return PaymentItem(
      id: map['id']?.toString() ?? '',
      receiptNo: (map['receipt_no'] ?? map['receiptNo'] ?? 'RCP-0000').toString(),
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      studentName: (map['student_name'] ?? map['studentName'] ?? 'Resident').toString(),
      room: map['room']?.toString() ?? 'Room 101A',
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : (double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0),
      date: map['date']?.toString() ?? 'Recently',
      isPaid: map['is_paid'] == true || map['isPaid'] == true,
      month: map['month']?.toString() ?? 'April 2025',
      method: map['method']?.toString() ?? 'bKash',
      trxId: (map['trx_id'] ?? map['trxId'] ?? map['transaction_id'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receipt_no': receiptNo,
      'user_id': userId,
      'student_name': studentName,
      'room': room,
      'amount': amount,
      'date': date,
      'is_paid': isPaid,
      'month': month,
      'method': method,
      'trx_id': trxId,
    };
  }
}
