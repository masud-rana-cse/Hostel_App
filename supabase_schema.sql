-- ==============================================================
-- Hostel Management System - Complete Supabase Database Schema
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/oimewqkgeeonjrzxistp/sql/new
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
    guardian TEXT DEFAULT 'Hostel Board',
    joined_date TEXT DEFAULT 'Apr 2025',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add any missing columns to profiles if already created
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT DEFAULT '01700000000';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS student_id TEXT DEFAULT 'STD-000';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'student';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS department TEXT DEFAULT 'CSE';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS room TEXT DEFAULT '101A';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS address TEXT DEFAULT 'Sector 9, Uttara, Dhaka';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS guardian TEXT DEFAULT 'Hostel Board';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS joined_date TEXT DEFAULT 'Apr 2025';

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to profiles" ON public.profiles;
CREATE POLICY "Allow all access to profiles"
    ON public.profiles FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

-- --------------------------------------------------------------
-- 2. STUDENTS TABLE (Both 'students' & 'student' compatible)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.students (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    student_id TEXT NOT NULL DEFAULT '',
    room TEXT NOT NULL DEFAULT '',
    phone TEXT DEFAULT '01712345678',
    department TEXT DEFAULT 'CSE',
    joined_date TEXT DEFAULT 'Apr 2025',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Upgrade existing 'student' table (if user created singular 'student' with 4 columns)
CREATE TABLE IF NOT EXISTS public.student (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    student_id TEXT NOT NULL DEFAULT '',
    room TEXT NOT NULL DEFAULT '',
    phone TEXT DEFAULT '01712345678',
    department TEXT DEFAULT 'CSE',
    joined_date TEXT DEFAULT 'Apr 2025',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.student ADD COLUMN IF NOT EXISTS name TEXT NOT NULL DEFAULT '';
ALTER TABLE public.student ADD COLUMN IF NOT EXISTS student_id TEXT NOT NULL DEFAULT '';
ALTER TABLE public.student ADD COLUMN IF NOT EXISTS room TEXT NOT NULL DEFAULT '';
ALTER TABLE public.student ADD COLUMN IF NOT EXISTS phone TEXT DEFAULT '01712345678';
ALTER TABLE public.student ADD COLUMN IF NOT EXISTS department TEXT DEFAULT 'CSE';
ALTER TABLE public.student ADD COLUMN IF NOT EXISTS joined_date TEXT DEFAULT 'Apr 2025';
ALTER TABLE public.student ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to students" ON public.students;
CREATE POLICY "Allow all access to students" ON public.students FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all access to student" ON public.student;
CREATE POLICY "Allow all access to student" ON public.student FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- --------------------------------------------------------------
-- 3. STAFF TABLE (Hostel Employees & Wardens)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.staff (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    shift TEXT NOT NULL,
    salary TEXT NOT NULL,
    phone TEXT NOT NULL DEFAULT '01700000000',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to staff" ON public.staff;
CREATE POLICY "Allow all access to staff" ON public.staff FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

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
    date TEXT NOT NULL DEFAULT 'Recently',
    status TEXT NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS user_id TEXT DEFAULT '';
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'General';
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'PENDING';

ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to complaints" ON public.complaints;
CREATE POLICY "Allow all access to complaints" ON public.complaints FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- --------------------------------------------------------------
-- 5. PAYMENTS TABLE (Hostel Rent & Fees Receipts)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payments (
    id TEXT PRIMARY KEY,
    receipt_no TEXT NOT NULL,
    user_id TEXT DEFAULT '',
    student_name TEXT NOT NULL,
    room TEXT NOT NULL,
    amount NUMERIC NOT NULL DEFAULT 3000,
    date TEXT NOT NULL DEFAULT 'Recently',
    is_paid BOOLEAN NOT NULL DEFAULT false,
    month TEXT DEFAULT 'May 2025',
    method TEXT DEFAULT 'bKash',
    trx_id TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS user_id TEXT DEFAULT '';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS month TEXT DEFAULT 'May 2025';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS method TEXT DEFAULT 'bKash';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS trx_id TEXT DEFAULT '';

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to payments" ON public.payments;
CREATE POLICY "Allow all access to payments" ON public.payments FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- --------------------------------------------------------------
-- 6. AUTOMATED TRIGGER: USER REGISTRATION SYNC (Email & Google OAuth)
-- --------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role TEXT;
    v_name TEXT;
    v_student_id TEXT;
    v_room TEXT;
    v_phone TEXT;
    v_dept TEXT;
BEGIN
    v_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        split_part(NEW.email, '@', 1)
    );
    v_role := COALESCE(
        NEW.raw_user_meta_data->>'role',
        CASE WHEN LOWER(NEW.email) LIKE '%admin%' THEN 'admin' ELSE 'student' END
    );
    v_student_id := COALESCE(NEW.raw_user_meta_data->>'student_id', 'STD-' || SUBSTR(NEW.id::text, 1, 6));
    v_room := COALESCE(NEW.raw_user_meta_data->>'room', '101A');
    v_phone := COALESCE(NEW.raw_user_meta_data->>'phone', '01700000000');
    v_dept := COALESCE(NEW.raw_user_meta_data->>'department', 'CSE');

    -- 1. Insert/Update in profiles table
    INSERT INTO public.profiles (
        id, name, email, phone, student_id, role, department, room, joined_date
    )
    VALUES (
        NEW.id, v_name, NEW.email, v_phone, v_student_id, v_role, v_dept, v_room, to_char(now(), 'Mon DD, YYYY')
    )
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        email = EXCLUDED.email,
        phone = COALESCE(EXCLUDED.phone, public.profiles.phone);

    -- 2. If student, also automatically register in students and student tables
    IF v_role = 'student' THEN
        INSERT INTO public.students (
            id, name, student_id, room, phone, department, joined_date
        )
        VALUES (
            NEW.id::text, v_name, v_student_id, v_room, v_phone, v_dept, to_char(now(), 'Mon DD, YYYY')
        )
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            phone = EXCLUDED.phone;

        BEGIN
            INSERT INTO public.student (
                id, name, student_id, room, phone, department, joined_date
            )
            VALUES (
                NEW.id::text, v_name, v_student_id, v_room, v_phone, v_dept, to_char(now(), 'Mon DD, YYYY')
            )
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                phone = EXCLUDED.phone;
        EXCEPTION WHEN OTHERS THEN
            -- Ignore if student table has different schema constraint
        END;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- --------------------------------------------------------------
-- 7. ENABLE SUPABASE REALTIME
-- --------------------------------------------------------------
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE public.students;
ALTER PUBLICATION supabase_realtime ADD TABLE public.student;
ALTER PUBLICATION supabase_realtime ADD TABLE public.staff;
ALTER PUBLICATION supabase_realtime ADD TABLE public.complaints;
ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;

-- ==============================================================
-- 8. HELPER INSTRUCTIONS
-- --------------------------------------------------------------
-- To promote any registered user to Admin:
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'YOUR_EMAIL@gmail.com';
-- ==============================================================
