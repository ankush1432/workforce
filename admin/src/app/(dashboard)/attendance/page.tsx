"use client";

import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";

interface AttendanceRow {
  id: number;
  attendance_date: string;
  check_in_at?: string;
  check_out_at?: string;
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
          { key: "check_in_at", header: "Check In" },
          { key: "check_out_at", header: "Check Out" },
          { key: "status", header: "Status" },
        ]}
      />
    </div>
  );
}
