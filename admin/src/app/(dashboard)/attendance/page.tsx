"use client";

import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";

interface AttendanceRow {
  id: number;
  attendance_date: string;
  check_in_at?: string;
  check_out_at?: string;
  check_in_confidence?: number;
  check_out_confidence?: number;
  checkin_face_image_url?: string | null;
  checkout_face_image_url?: string | null;
  status: string;
  employee?: { full_name: string; employee_code: string };
}

export default function AttendancePage() {
  const { data, isLoading } = useQuery({
    queryKey: ["attendance"],
    queryFn: async () => (await apiClient.get("/attendance")).data.data ?? [],
  });

  return (
    <div className="space-y-6">
      <h1 className="page-title">Attendance Monitoring</h1>
      <DataTable<AttendanceRow>
        loading={isLoading}
        data={data ?? []}
        columns={[
          {
            key: "employee",
            header: "Employee",
            render: (r) => r.employee?.full_name ?? "—",
          },
          { key: "attendance_date", header: "Date" },
          {
            key: "check_in_at",
            header: "Check In",
            render: (r) => r.check_in_at ? new Date(r.check_in_at).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }) : "—",
          },
          {
            key: "checkin_face_image_url",
            header: "Check In Face",
            render: (r) =>
              r.checkin_face_image_url ? (
                <img
                  src={r.checkin_face_image_url}
                  alt="Check in face"
                  className="w-12 h-12 rounded-full object-cover cursor-pointer"
                  onClick={() => r.checkin_face_image_url && window.open(r.checkin_face_image_url, '_blank')}
                />
              ) : (
                <span className="text-slate-400">No image</span>
              ),
          },
          {
            key: "check_in_confidence",
            header: "Check In Confidence",
            render: (r) => (r.check_in_confidence ? (r.check_in_confidence * 100).toFixed(1) + "%" : "N/A"),
          },
          {
            key: "check_out_at",
            header: "Check Out",
            render: (r) => r.check_out_at ? new Date(r.check_out_at).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }) : "—",
          },
          {
            key: "checkout_face_image_url",
            header: "Check Out Face",
            render: (r) =>
              r.checkout_face_image_url ? (
                <img
                  src={r.checkout_face_image_url}
                  alt="Check out face"
                  className="w-12 h-12 rounded-full object-cover cursor-pointer"
                  onClick={() => r.checkout_face_image_url && window.open(r.checkout_face_image_url, '_blank')}
                />
              ) : (
                <span className="text-slate-400">No image</span>
              ),
          },
          {
            key: "check_out_confidence",
            header: "Check Out Confidence",
            render: (r) => (r.check_out_confidence ? (r.check_out_confidence * 100).toFixed(1) + "%" : "N/A"),
          },
          { key: "status", header: "Status" },
        ]}
      />
    </div>
  );
}
