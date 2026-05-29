"use client";

import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";
import type { Employee } from "@/lib/api/types";

export default function FaceRegistrationsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["face-registrations"],
    queryFn: async () => {
      const res = await apiClient.get("/employees", { params: { face_registered: false } });
      return res.data.data ?? [];
    },
  });

  return (
    <div className="space-y-6">
      <h1 className="page-title">Face Registrations</h1>
      <p className="text-slate-400">Employees pending face enrollment</p>
      <DataTable<Employee>
        loading={isLoading}
        data={data ?? []}
        emptyMessage="All employees have registered faces"
        columns={[
          { key: "employee_code", header: "Code" },
          {
            key: "full_name",
            header: "Name",
            render: (r) => r.full_name ?? `${r.first_name} ${r.last_name}`,
          },
          { key: "department", header: "Department" },
        ]}
      />
    </div>
  );
}
