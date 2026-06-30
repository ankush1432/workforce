"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { PageHeader } from "@/components/layout/page-header";
import { DesignationFormDialog } from "@/components/designations/designation-form-dialog";
import type { Designation, Department } from "@/lib/api/types";
import { Button } from "@/components/ui/button";

function StatusBadge({ active }: { active: boolean }) {
  return (
    <span className={active ? "status-badge status-active" : "status-badge status-inactive"}>
      {active ? "Active" : "Inactive"}
    </span>
  );
}

export default function DesignationsPage() {
  const qc = useQueryClient();
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Designation | null>(null);
  const [deleting, setDeleting] = useState<Designation | null>(null);

  const { data: departments = [] } = useQuery({
    queryKey: ["departments"],
    queryFn: async () => {
      const res = await apiClient.get("/departments", { params: { per_page: 100 } });
      return (res.data.data ?? []) as Department[];
    },
  });

  const { data, isLoading } = useQuery({
    queryKey: ["designations"],
    queryFn: async () => {
      const res = await apiClient.get("/designations", { params: { per_page: 100 } });
      return (res.data.data ?? []) as Designation[];
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => apiClient.delete(`/designations/${id}`),
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["designations"] });
      setDeleting(null);
    },
  });

  const getDepartmentName = (departmentId: number | null | undefined) => {
    if (!departmentId) return "-";
    const dept = departments.find((d) => d.id === departmentId);
    return dept?.name ?? "-";
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Designation Management"
        description="Define job titles and roles within departments"
        action={
          <Button
            onClick={() => {
              setEditing(null);
              setFormOpen(true);
            }}
          >
            <Plus className="h-4 w-4" />
            Add designation
          </Button>
        }
      />

      <DataTable<Designation>
        loading={isLoading}
        data={data ?? []}
        emptyMessage="No designations yet. Add your first designation."
        columns={[
          { key: "title", header: "Title" },
          { key: "code", header: "Code" },
          {
            key: "department_id",
            header: "Department",
            render: (r) => getDepartmentName(r.department_id),
          },
          { key: "description", header: "Description" },
          {
            key: "is_active",
            header: "Status",
            render: (r) => <StatusBadge active={r.is_active} />,
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

      <DesignationFormDialog
        open={formOpen}
        designation={editing}
        departments={departments}
        onClose={() => {
          setFormOpen(false);
          setEditing(null);
        }}
      />

      <ConfirmDialog
        open={!!deleting}
        title="Delete designation?"
        description={`Remove "${deleting?.title}"? Employees with this designation may be affected.`}
        loading={deleteMutation.isPending}
        onCancel={() => setDeleting(null)}
        onConfirm={() => deleting && deleteMutation.mutate(deleting.id)}
      />
    </div>
  );
}
