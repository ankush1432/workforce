export interface User {
  id: number;
  name: string;
  email: string;
  role: string;
  company_id?: number;
  is_active: boolean;
}

export interface Company {
  id: number;
  name: string;
  code: string;
  email?: string;
  phone?: string;
  address?: string;
  timezone: string;
  is_active: boolean;
}

export interface Site {
  id: number;
  company_id: number;
  name: string;
  code: string;
  address?: string;
  latitude?: number;
  longitude?: number;
  geofence_radius_m?: number;
  is_active: boolean;
}

export interface Department {
  id: number;
  company_id: number;
  name: string;
  code: string;
  description?: string | null;
  is_active: boolean;
}

export interface Designation {
  id: number;
  company_id: number;
  department_id?: number | null;
  title: string;
  code: string;
  description?: string | null;
  is_active: boolean;
}

export interface Employee {
  id: number;
  company_id: number;
  site_id: number;
  supervisor_id?: number | null;
  department_id?: number | null;
  designation_id?: number | null;
  shift_id?: number | null;
  employee_code: string;
  first_name: string;
  last_name: string;
  full_name: string;
  email?: string;
  phone?: string;
  department?: string;
  designation?: string;
  face_registered: boolean;
  is_active: boolean;
  supervisor?: Supervisor | null;
  department_relation?: Department | null;
  designation_relation?: Designation | null;
  shift?: Shift | null;
}

export interface Supervisor {
  id: number;
  company_id: number;
  site_id?: number;
  employee_code: string;
  first_name: string;
  last_name: string;
  full_name: string;
  email: string;
  phone?: string;
  is_active: boolean;
}

export interface Shift {
  id: number;
  company_id: number;
  site_id?: number | null;
  name: string;
  start_time: string;
  end_time: string;
  grace_minutes: number;
  is_active: boolean;
}

export interface Event {
  id: number;
  title: string;
  description?: string | null;
  location?: string | null;
  start_date: string;
  end_date: string;
  banner_image?: string | null;
  banner_image_url?: string | null;
  status: "draft" | "published" | "unpublished";
  created_by?: number | null;
  created_at?: string;
  updated_at?: string;
}

// export interface Wage {
//   id: number;
//   employee_id: number;
//   company_id: number;
//   year: number;
//   month: number;
//   hourly_rate?: string | number;
//   daily_rate?: string | number;
//   monthly_salary?: string | number;
//   status: string;
// }
export interface WageEmployee {
  id: number;
  full_name?: string;
  first_name?: string;
  last_name?: string;
}

export interface Wage {
  id: number;

  company_id?: number;

  employee_id: number;

  employee?: WageEmployee | null;

  year: number;
  month: number;

  hourly_rate?: number | null;
  daily_rate?: number | null;

  days_worked?: number | null;
  hours_worked?: number | null;

  gross_amount?: number | null;
  deductions?: number | null;
  net_amount?: number | null;

  status: "draft" | "approved" | "paid";

  created_at?: string;
  updated_at?: string;
}
export interface WeeklyTrendItem {
  date: string;
  count: number;
}
export interface DashboardStats {
   employees: number;
  present_today: number;
  face_registered: number;
  sites: number;
  attendance_rate: number;
  absent_today: number;
  face_pending: number;

  weekly_trend: WeeklyTrendItem[];
}
