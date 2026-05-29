"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { PageHeader } from "@/components/layout/page-header";
import { SiteFormDialog } from "@/components/sites/site-form-dialog";
import type { Site } from "@/lib/api/types";
import { Button } from "@/components/ui/button";

function StatusBadge({ active }: { active: boolean }) {
  return (
    <span className={active ? "status-badge status-active" : "status-badge status-inactive"}>
      {active ? "Active" : "Inactive"}
    </span>
  );
}

export default function SitesPage() {
  const qc = useQueryClient();
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Site | null>(null);
  const [deleting, setDeleting] = useState<Site | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["sites"],
    queryFn: async () => (await apiClient.get("/sites")).data.data ?? [],
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => apiClient.delete(`/sites/${id}`),
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["sites"] });
      setDeleting(null);
    },
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Locations"
        description="Manage office and site locations for attendance and geofencing"
        action={
          <Button
            onClick={() => {
              setEditing(null);
              setFormOpen(true);
            }}
          >
            <Plus className="h-4 w-4" />
            Add location
          </Button>
        }
      />

      <DataTable<Site>
        loading={isLoading}
        data={data ?? []}
        emptyMessage="No locations yet. Add your first site or office."
        columns={[
          { key: "code", header: "Code" },
          { key: "name", header: "Name" },
          {
            key: "address",
            header: "Address",
            render: (r) => r.address ?? "—",
          },
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

      <SiteFormDialog
        open={formOpen}
        site={editing}
        onClose={() => {
          setFormOpen(false);
          setEditing(null);
        }}
      />

      <ConfirmDialog
        open={!!deleting}
        title="Delete location?"
        description={`Remove "${deleting?.name}"? Employees assigned to this location must be reassigned first.`}
        loading={deleteMutation.isPending}
        onCancel={() => setDeleting(null)}
        onConfirm={() => deleting && deleteMutation.mutate(deleting.id)}
      />
    </div>
  );
}
