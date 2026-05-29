"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { PageHeader } from "@/components/layout/page-header";
import { ShiftFormDialog } from "@/components/shifts/shift-form-dialog";
import type { Shift } from "@/lib/api/types";
import { Button } from "@/components/ui/button";

function StatusBadge({ active }: { active: boolean }) {
  return (
    <span className={active ? "status-badge status-active" : "status-badge status-inactive"}>
      {active ? "Active" : "Inactive"}
    </span>
  );
}

function formatTime(t: string) {
  return t?.length >= 5 ? t.slice(0, 5) : t;
}

export default function ShiftsPage() {
  const qc = useQueryClient();
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Shift | null>(null);
  const [deleting, setDeleting] = useState<Shift | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["shifts"],
    queryFn: async () => {
      const res = await apiClient.get("/shifts", { params: { per_page: 100 } });
      return (res.data.data ?? []) as Shift[];
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => apiClient.delete(`/shifts/${id}`),
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["shifts"] });
      setDeleting(null);
    },
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Shift Management"
        description="Define work shifts with start times, end times, and grace periods"
        action={
          <Button
            onClick={() => {
              setEditing(null);
              setFormOpen(true);
            }}
          >
            <Plus className="h-4 w-4" />
            Add shift
          </Button>
        }
      />

      <DataTable<Shift>
        loading={isLoading}
        data={data ?? []}
        emptyMessage="No shifts yet. Add your first shift schedule."
        columns={[
          { key: "name", header: "Shift" },
          {
            key: "start_time",
            header: "Start",
            render: (r) => formatTime(r.start_time),
          },
          {
            key: "end_time",
            header: "End",
            render: (r) => formatTime(r.end_time),
          },
          { key: "grace_minutes", header: "Grace (min)" },
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

      <ShiftFormDialog
        open={formOpen}
        shift={editing}
        onClose={() => {
          setFormOpen(false);
          setEditing(null);
        }}
      />

      <ConfirmDialog
        open={!!deleting}
        title="Delete shift?"
        description={`Remove "${deleting?.name}"? Attendance linked to this shift may be affected.`}
        loading={deleteMutation.isPending}
        onCancel={() => setDeleting(null)}
        onConfirm={() => deleting && deleteMutation.mutate(deleting.id)}
      />
    </div>
  );
}
