-- ==============================================================
-- Hostel Management System - Complete Supabase Backend Database Schema
-- Run this in: https://supabase.com/dashboard/project/oimewqkgeeonjrzxistp/sql/new
-- ==============================================================

-- --------------------------------------------------------------
-- 1. PROFILES TABLE (Authentication Profiles & User Roles)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT '',
    email TEXT NOT NULL DEFAULT '',
    phone TEXT DEFAULT '01700000000',
    student_id TEXT DEFAULT 'STD-000',
    role TEXT NOT NULL DEFAULT 'student', -- 'admin' or 'student'
    department TEXT DEFAULT 'CSE',
    room TEXT DEFAULT '101A',
    address TEXT DEFAULT 'Sector 9, Uttara, Dhaka',
    guardian TEXT DEFAULT 'Md. Abdur Rahim (01711000000)',
    joined_date TEXT DEFAULT 'Apr 2025',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Profiles are readable by authenticated users" ON public.profiles;
CREATE POLICY "Profiles are readable by authenticated users"
    ON public.profiles FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Trigger: Automatically create profile on new User signup (Email or Google OAuth)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        name,
        email,
        phone,
        student_id,
        role,
        department,
        room
    )
    VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            split_part(NEW.email, '@', 1)
        ),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'phone', '01700000000'),
        COALESCE(NEW.raw_user_meta_data->>'student_id', 'STD-' || SUBSTR(NEW.id::text, 1, 6)),
        COALESCE(
            NEW.raw_user_meta_data->>'role',
            CASE WHEN LOWER(NEW.email) LIKE '%admin%' THEN 'admin' ELSE 'student' END
        ),
        COALESCE(NEW.raw_user_meta_data->>'department', 'CSE'),
        COALESCE(NEW.raw_user_meta_data->>'room', '101A')
    )
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        email = EXCLUDED.email;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- --------------------------------------------------------------
-- 2. STUDENTS TABLE (Resident Roster)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.students (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    student_id TEXT NOT NULL,
    room TEXT NOT NULL,
    phone TEXT DEFAULT '01712345678',
    department TEXT DEFAULT 'CSE',
    joined_date TEXT DEFAULT 'Jan 15, 2024',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated read students" ON public.students;
CREATE POLICY "Allow authenticated read students" ON public.students FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Allow authenticated insert students" ON public.students;
CREATE POLICY "Allow authenticated insert students" ON public.students FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated update students" ON public.students;
CREATE POLICY "Allow authenticated update students" ON public.students FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "Allow authenticated delete students" ON public.students;
CREATE POLICY "Allow authenticated delete students" ON public.students FOR DELETE TO authenticated USING (true);

-- Seed initial students
INSERT INTO public.students (id, name, student_id, room, phone, department, joined_date)
VALUES
    ('1', 'Md. Masud Rana', '241071031', '204B', '01712345678', 'CSE (Computer Science)', 'Jan 15, 2024'),
    ('2', 'Jonaki Akter', '241071032', '301A', '01812345672', 'BBA (Management)', 'Feb 10, 2024'),
    ('3', 'Rakib Hasan', '241071035', '105C', '01912345673', 'EEE (Electrical)', 'Mar 01, 2024'),
    ('4', 'Sadia Islam', '241071037', '202A', '01612345674', 'Pharmacy', 'Mar 15, 2024')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 3. STAFF TABLE (Hostel Employees & Wardens)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.staff (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    shift TEXT NOT NULL,
    salary TEXT NOT NULL,
    phone TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated read staff" ON public.staff;
CREATE POLICY "Allow authenticated read staff" ON public.staff FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Allow authenticated write staff" ON public.staff;
CREATE POLICY "Allow authenticated write staff" ON public.staff FOR ALL TO authenticated USING (true);

-- Seed initial staff
INSERT INTO public.staff (id, name, role, shift, salary, phone)
VALUES
    ('1', 'Kamal Hossain', 'Warden', 'Morning (7 AM–3 PM)', '৳45,000/mo', '01712345671'),
    ('2', 'Salam Mia', 'Security Guard', 'Night (8 PM–6 AM)', '৳32,000/mo', '01812345672'),
    ('3', 'Rafiq Uddin', 'Cleaner', 'Day (8 AM–4 PM)', '৳28,000/mo', '01912345673'),
    ('4', 'Jahangir Alam', 'Chief Cook', 'Split (6 AM–2 PM, 6 PM–9 PM)', '৳35,000/mo', '01612345674')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 4. COMPLAINTS TABLE (Resident Issues & Tickets)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.complaints (
    id TEXT PRIMARY KEY,
    ticket_no TEXT NOT NULL,
    user_id TEXT DEFAULT '',
    student_name TEXT NOT NULL,
    room TEXT NOT NULL,
    category TEXT DEFAULT 'General',
    description TEXT NOT NULL,
    date TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING', -- 'PENDING' or 'RESOLVED'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated read complaints" ON public.complaints;
CREATE POLICY "Allow authenticated read complaints" ON public.complaints FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Allow authenticated write complaints" ON public.complaints;
CREATE POLICY "Allow authenticated write complaints" ON public.complaints FOR ALL TO authenticated USING (true);

-- Seed initial complaints
INSERT INTO public.complaints (id, ticket_no, user_id, student_name, room, category, description, date, status)
VALUES
    ('1', 'Ticket #CMP-104', 'user_2', 'Jonaki Akter', 'Room 304', 'Plumbing', 'Water leakage in bathroom pipe', 'Apr 12, 2025', 'PENDING'),
    ('2', 'Ticket #CMP-099', 'user_3', 'Tanvir Ahmed', 'Room 102', 'Electrical', 'Corridor tube light replaced', 'Apr 10, 2025', 'RESOLVED'),
    ('3', 'Ticket #CMP-095', 'user_1', 'Md. Masud Rana', 'Room 204B', 'Appliances', 'Ceiling fan making squeaking noise', 'Apr 06, 2025', 'RESOLVED')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 5. PAYMENTS TABLE (Hostel Rent & Fees Receipts)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payments (
    id TEXT PRIMARY KEY,
    receipt_no TEXT NOT NULL,
    student_name TEXT NOT NULL,
    room TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    date TEXT NOT NULL,
    is_paid BOOLEAN NOT NULL DEFAULT false,
    month TEXT DEFAULT 'April 2025',
    method TEXT DEFAULT 'bKash',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated read payments" ON public.payments;
CREATE POLICY "Allow authenticated read payments" ON public.payments FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Allow authenticated write payments" ON public.payments;
CREATE POLICY "Allow authenticated write payments" ON public.payments FOR ALL TO authenticated USING (true);

-- Seed initial payments
INSERT INTO public.payments (id, receipt_no, student_name, room, amount, date, is_paid, month, method)
VALUES
    ('1', 'RCP-9012', 'Md. Masud Rana', 'Room 204B', 3000.0, 'Apr 10, 2025', true, 'April 2025', 'bKash'),
    ('2', 'RCP-9013', 'Jonaki Akter', 'Room 301A', 3000.0, 'Apr 08, 2025', false, 'April 2025', 'Nagad'),
    ('3', 'RCP-9014', 'Rakib Hasan', 'Room 105C', 3000.0, 'Apr 05, 2025', true, 'April 2025', 'Bank Transfer'),
    ('4', 'RCP-9015', 'Sadia Islam', 'Room 202A', 3000.0, 'Apr 02, 2025', false, 'April 2025', 'Cash')
ON CONFLICT (id) DO NOTHING;

-- ==============================================================
-- 6. Helper: Promote a User to Admin in Supabase
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'YOUR_EMAIL@gmail.com';
-- ==============================================================
