import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Dedicated Backend Authentication Service for Supabase Auth
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  /// Auto-creates 'admin@gmail.com' in Supabase Auth if not already registered
  Future<void> ensureAdminAccountExists() async {
    try {
      final res = await _supabase.auth.signUp(
        email: 'admin@gmail.com',
        password: 'password123',
        data: {
          'name': 'Hostel Administrator',
          'phone': '01700000000',
          'student_id': 'ADM-001',
          'role': 'admin',
          'department': 'Hostel Administration',
          'room': 'Office 101',
        },
      );
      if (res.user != null) {
        try {
          await _supabase.from('profiles').upsert({
            'id': res.user!.id,
            'name': 'Hostel Administrator',
            'email': 'admin@gmail.com',
            'phone': '01700000000',
            'student_id': 'ADM-001',
            'role': 'admin',
            'department': 'Hostel Administration',
            'room': 'Office 101',
          });
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Admin account auto-seed notice: $e');
    }
  }

  /// Sign Up with Email and Password + Store User Profile in Supabase
  Future<(bool, String)> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String studentId,
    required String role,
    String department = 'CSE',
    String room = '101A',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || cleanPass.isEmpty || name.trim().isEmpty) {
      return (false, 'All required fields must be filled.');
    }

    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: cleanEmail,
        password: cleanPass,
        data: {
          'name': name.trim(),
          'phone': phone.trim(),
          'student_id': studentId.trim(),
          'role': role.toLowerCase(),
          'department': department,
          'room': room,
        },
      );

      final user = res.user;
      if (user == null) {
        return (false, 'Sign up failed. Please check your credentials.');
      }

      // Upsert profile in 'profiles' table
      try {
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'name': name.trim(),
          'email': cleanEmail,
          'phone': phone.trim(),
          'student_id': studentId.trim(),
          'role': role.toLowerCase(),
          'department': department,
          'room': room,
        });
      } catch (e) {
        debugPrint('Notice saving to profiles table: $e');
      }

      // Upsert student in 'students' or 'student' roster table
      if (role.toLowerCase() == 'student') {
        final studentMap = {
          'id': user.id,
          'name': name.trim(),
          'student_id': studentId.trim(),
          'room': room,
          'phone': phone.trim(),
          'department': department,
          'joined_date': 'Apr 2025',
        };
        try {
          await _supabase.from('students').upsert(studentMap);
        } catch (_) {
          try {
            await _supabase.from('student').upsert(studentMap);
          } catch (e) {
            debugPrint('Notice saving to student table: $e');
          }
        }
      }

      if (res.session != null) {
        return (true, 'Account created successfully!');
      } else {
        return (
          true,
          'Account created! A verification email has been sent to $cleanEmail. Please confirm your email before signing in.'
        );
      }
    } on AuthException catch (e) {
      return (false, e.message);
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Sign In with Email and Password
  Future<(bool, String)> signInWithPassword(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || cleanPass.isEmpty) {
      return (false, 'Please enter both email and password.');
    }

    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: cleanPass,
      );

      if (res.user != null) {
        return (true, 'Success');
      } else {
        return (false, 'Failed to sign in. Please verify your credentials.');
      }
    } on AuthException catch (e) {
      return (false, e.message);
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Google OAuth & Native Sign In using Android & Web Client IDs from .env
  Future<(bool, String)> signInWithGoogle() async {
    try {
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
          dotenv.env['GOOGLE_CLIENT_ID'] ??
          '91377156454-flemhjth60f5a00er8rtqaiqrjgrlln8.apps.googleusercontent.com';

      final androidClientId = dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ??
          '91377156454-ourk4oie19rdv8iumf608uhb9juktslt.apps.googleusercontent.com';

      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.hostelapp://login-callback',
        );
        return (true, 'Success');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        clientId: kIsWeb ? webClientId : androidClientId,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return (false, 'Google Sign-In canceled by user.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken != null) {
        final res = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        if (res.user != null) return (true, 'Success');
      }

      // Try OAuth Redirect fallback
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.hostelapp://login-callback',
      );
      return (true, 'Success');
    } on AuthException catch (e) {
      if (e.message.contains('missing OAuth secret') || e.statusCode == '400') {
        return (
          false,
          'Supabase Google Provider Notice: Please paste your Google Client Secret into Supabase Auth Settings.'
        );
      }
      return (false, e.message);
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Load user profile from Supabase profiles table
  Future<AppUser?> fetchUserProfile(User user) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // First login or OAuth account: persist initial profile in Supabase
        final profile = AppUser.fromSupabase(user, null);
        try {
          await _supabase.from('profiles').upsert(profile.toMap());
          if (!profile.isAdmin) {
            final studentData = {
              'id': profile.id,
              'name': profile.name,
              'student_id': profile.studentId,
              'room': profile.room,
              'phone': profile.phone,
              'department': profile.department,
              'joined_date': profile.joinedDate,
            };
            try {
              await _supabase.from('students').upsert(studentData);
            } catch (_) {
              try {
                await _supabase.from('student').upsert(studentData);
              } catch (_) {}
            }
          }
        } catch (e) {
          debugPrint('Notice saving initial profile for user: $e');
        }
        return profile;
      }

      return AppUser.fromSupabase(user, data);
    } catch (e) {
      debugPrint('Notice fetching profile from Supabase: $e');
      return AppUser.fromSupabase(user, null);
    }
  }

  /// Update current user profile details
  Future<bool> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String department,
    required String room,
    required String address,
    required String studentId,
  }) async {
    try {
      // 1. Update user metadata in auth.users
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': name,
            'phone': phone,
            'department': department,
            'room': room,
            'student_id': studentId,
          },
        ),
      );

      // 2. Update profiles table
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

  /// Change Password
  Future<bool> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
      return true;
    } catch (e) {
      debugPrint('Error changing password in Supabase: $e');
      return false;
    }
  }

  /// Reset Password via Email
  Future<(bool, String)> resetPassword(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      return (false, 'Please enter your email address.');
    }
    try {
      await _supabase.auth.resetPasswordForEmail(cleanEmail);
      return (true, 'Password reset instructions have been sent to $cleanEmail');
    } on AuthException catch (e) {
      return (false, e.message);
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error during Supabase signOut: $e');
    }
  }
}
