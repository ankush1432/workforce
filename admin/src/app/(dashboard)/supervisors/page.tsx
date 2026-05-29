"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { SupervisorFormDialog } from "@/components/supervisors/supervisor-form-dialog";
import type { Supervisor } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { PageHeader } from "@/components/layout/page-header";

export default function SupervisorsPage() {
  const qc = useQueryClient();
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Supervisor | null>(null);
  const [deleting, setDeleting] = useState<Supervisor | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["supervisors"],
    queryFn: async () => {
      const res = await apiClient.get("/supervisors", { params: { per_page: 100 } });
      return (res.data.data ?? []) as Supervisor[];
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => apiClient.delete(`/supervisors/${id}`),
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["supervisors"] });
      setDeleting(null);
    },
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Supervisors"
        description="Site supervisor accounts and access"
        action={
          <Button
            onClick={() => {
              setEditing(null);
              setFormOpen(true);
            }}
          >
            <Plus className="h-4 w-4" />
            Add supervisor
          </Button>
        }
      />
      <DataTable<Supervisor>
        loading={isLoading}
        data={data ?? []}
        columns={[
          { key: "employee_code", header: "Code" },
          {
            key: "full_name",
            header: "Name",
            render: (r) => r.full_name ?? `${r.first_name} ${r.last_name}`,
          },
          { key: "email", header: "Email" },
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

      <SupervisorFormDialog
        open={formOpen}
        supervisor={editing}
        onClose={() => {
          setFormOpen(false);
          setEditing(null);
        }}
      />

      <ConfirmDialog
        open={!!deleting}
        title="Delete supervisor?"
        description={`Remove ${deleting?.full_name ?? deleting?.email}? This cannot be undone.`}
        loading={deleteMutation.isPending}
        onCancel={() => setDeleting(null)}
        onConfirm={() => deleting && deleteMutation.mutate(deleting.id)}
      />
    </div>
  );
}
