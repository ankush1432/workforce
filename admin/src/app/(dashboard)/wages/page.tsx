"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { PageHeader } from "@/components/layout/page-header";
import { WageFormDialog } from "@/components/wages/wage-form-dialog";
import type { Wage } from "@/lib/api/types";
import { Button } from "@/components/ui/button";

const MONTH_NAMES = [
  "",
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

function statusClass(status: string) {
  if (status === "paid") return "status-badge status-active";
  if (status === "approved") return "status-badge bg-blue-50 text-blue-700 ring-1 ring-blue-600/20";
  return "status-badge status-inactive";
}

export default function WagesPage() {
  const qc = useQueryClient();
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Wage | null>(null);
  const [deleting, setDeleting] = useState<Wage | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["wages"],
    queryFn: async () => {
      const res = await apiClient.get("/wages", { params: { per_page: 100 } });
      return (res.data.data ?? []) as Wage[];
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => apiClient.delete(`/wages/${id}`),
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["wages"] });
      setDeleting(null);
    },
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Wage Management"
        description="Monthly wage records per employee; filter by supervisor when adding"
        action={
          <Button
            onClick={() => {
              setEditing(null);
              setFormOpen(true);
            }}
          >
            <Plus className="h-4 w-4" />
            Add wage record
          </Button>
        }
      />

      <DataTable<Wage>
        loading={isLoading}
        data={data ?? []}
        emptyMessage="No wage records yet. Add a monthly wage for an employee."
        columns={[
          {
            key: "employee",
            header: "Employee",
            render: (r) => r.employee?.full_name ?? "—",
          },
          {
            key: "period",
            header: "Period",
            render: (r) => `${MONTH_NAMES[r.month] ?? r.month} ${r.year}`,
          },
          {
            key: "gross_amount",
            header: "Gross",
            render: (r) => (r.gross_amount != null ? String(r.gross_amount) : "—"),
          },
          {
            key: "net_amount",
            header: "Net",
            render: (r) => (r.net_amount != null ? String(r.net_amount) : "—"),
          },
          {
            key: "status",
            header: "Status",
            render: (r) => (
              <span className={statusClass(r.status)}>
                {r.status.charAt(0).toUpperCase() + r.status.slice(1)}
              </span>
            ),
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

      <WageFormDialog
        open={formOpen}
        wage={editing}
        onClose={() => {
          setFormOpen(false);
          setEditing(null);
        }}
      />

      <ConfirmDialog
        open={!!deleting}
        title="Delete wage record?"
        description="This monthly wage entry will be permanently removed."
        loading={deleteMutation.isPending}
        onCancel={() => setDeleting(null)}
        onConfirm={() => deleting && deleteMutation.mutate(deleting.id)}
      />
    </div>
  );
}
