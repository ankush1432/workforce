"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, ScanFace, Trash2 } from "lucide-react";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { EmployeeFormDialog } from "@/components/employees/employee-form-dialog";
import type { Employee } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { PageHeader } from "@/components/layout/page-header";

export default function EmployeesPage() {
  const qc = useQueryClient();
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Employee | null>(null);
  const [deleting, setDeleting] = useState<Employee | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["employees"],
    queryFn: async () => {
      const res = await apiClient.get("/employees", { params: { per_page: 100 } });
      return (res.data.data ?? []) as Employee[];
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => apiClient.delete(`/employees/${id}`),
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["employees"] });
      setDeleting(null);
    },
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Employees"
        description="Manage workforce records and face registration status"
        action={
          <Button
            onClick={() => {
              setEditing(null);
              setFormOpen(true);
            }}
          >
            <Plus className="h-4 w-4" />
            Add employee
          </Button>
        }
      />
      <DataTable<Employee>
        loading={isLoading}
        data={data ?? []}
        columns={[
          { key: "employee_code", header: "Code" },
          {
            key: "full_name",
            header: "Name",
            render: (r) => r.full_name ?? `${r.first_name} ${r.last_name}`,
          },
          {
            key: "department_relation",
            header: "Department",
            render: (r) => r.department_relation?.name ?? r.department ?? "-",
          },
          {
            key: "designation_relation",
            header: "Designation",
            render: (r) => r.designation_relation?.title ?? r.designation ?? "-",
          },
          {
            key: "shift",
            header: "Shift",
            render: (r) => r.shift?.name ?? "-",
          },
          {
            key: "supervisor",
            header: "Supervisor",
            render: (r) => r.supervisor ? `${r.supervisor.first_name} ${r.supervisor.last_name}` : "-",
          },
          {
            key: "face_registered",
            header: "Face",
            render: (r) =>
              r.face_registered ? (
                <span className="flex items-center gap-1 text-emerald-700">
                  <ScanFace className="h-4 w-4" /> Registered
                </span>
              ) : (
                <span className="text-amber-700">Pending</span>
              ),
          },
          {
            key: "is_active",
            header: "Status",
            render: (r) => (r.is_active ? "Active" : "Inactive"),
          },
          {
            key: "id",
            header: "Actions",
            render: (r) => (
              <div className="flex gap-1">
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => {
                    setEditing(r);
                    setFormOpen(true);
                  }}
                  aria-label="Edit"
                >
                  <Pencil className="h-4 w-4" />
                </Button>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => setDeleting(r)}
                  aria-label="Delete"
                >
                  <Trash2 className="h-4 w-4 text-red-600" />
                </Button>
              </div>
            ),
          },
        ]}
      />

      <EmployeeFormDialog
        open={formOpen}
        employee={editing}
        onClose={() => {
          setFormOpen(false);
          setEditing(null);
        }}
      />

      <ConfirmDialog
        open={!!deleting}
        title="Delete employee?"
        description={`Remove ${deleting?.full_name ?? deleting?.employee_code}? This cannot be undone.`}
        loading={deleteMutation.isPending}
        onCancel={() => setDeleting(null)}
        onConfirm={() => deleting && deleteMutation.mutate(deleting.id)}
      />
    </div>
  );
}
