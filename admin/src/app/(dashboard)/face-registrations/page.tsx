"use client";

import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";

interface FaceRegistration {
  id: number;
  employee_id: number;
  model_version: string;
  quality_score: number;
  registered_at: string;
  is_primary: boolean;
  face_image_url: string | null;
  employee: {
    id: number;
    employee_code: string;
    first_name: string;
    last_name: string;
    department_relation?: {
      name: string;
    };
    designation_relation?: {
      name: string;
    };
    supervisor?: {
      first_name: string;
      last_name: string;
    };
  };
}

export default function FaceRegistrationsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["face-registrations"],
    queryFn: async () => {
      const res = await apiClient.get("/face-embeddings");
      console.log("Full API response:", res.data);
      const result = res.data.data ?? [];
      console.log("Data array:", result);
      if (result.length > 0) {
        console.log("First record:", result[0]);
        console.log("First record employee:", result[0].employee);
      }
      return result;
    },
  });

  return (
    <div className="space-y-6">
      <h1 className="page-title">Face Registrations</h1>
      <p className="text-slate-400">All registered face embeddings</p>
      <DataTable<FaceRegistration>
        loading={isLoading}
        data={data ?? []}
        emptyMessage="No face registrations found"
        columns={[
          {
            key: "employee.employee_code",
            header: "Employee Code",
            render: (r) => r.employee?.employee_code ?? "N/A",
          },
          {
            key: "employee",
            header: "Employee Name",
            render: (r) => `${r.employee.first_name} ${r.employee.last_name}`,
          },
          {
            key: "employee.department_relation",
            header: "Department",
            render: (r) => r.employee.department_relation?.name ?? "N/A",
          },
          {
            key: "employee.designation_relation",
            header: "Designation",
            render: (r) => r.employee.designation_relation?.name ?? "N/A",
          },
          {
            key: "employee.supervisor",
            header: "Supervisor",
            render: (r) =>
              r.employee.supervisor
                ? `${r.employee.supervisor.first_name} ${r.employee.supervisor.last_name}`
                : "N/A",
          },
          {
            key: "face_image_url",
            header: "Face Image",
            render: (r) =>
              r.face_image_url ? (
                <img
                  src={r.face_image_url}
                  alt={`Face of ${r.employee.first_name} ${r.employee.last_name}`}
                  className="w-12 h-12 rounded-full object-cover"
                />
              ) : (
                <span className="text-slate-400">No image</span>
              ),
          },
          {
            key: "registered_at",
            header: "Registration Date",
            render: (r) => new Date(r.registered_at).toLocaleDateString(),
          },
          {
            key: "quality_score",
            header: "Quality Score",
            render: (r) => (r.quality_score ? (r.quality_score * 100).toFixed(1) + "%" : "N/A"),
          },
        ]}
      />
    </div>
  );
}
