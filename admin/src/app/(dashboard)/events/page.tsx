"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Trash2, Eye, EyeOff } from "lucide-react";
import { apiClient } from "@/lib/api/client";
import { DataTable } from "@/components/shared/data-table";
import { ConfirmDialog } from "@/components/shared/confirm-dialog";
import { PageHeader } from "@/components/layout/page-header";
import { EventFormDialog } from "@/components/events/event-form-dialog";
import type { Event } from "@/lib/api/types";
import { Button } from "@/components/ui/button";

function StatusBadge({ status }: { status: Event["status"] }) {
  const cls =
    status === "published"
      ? "status-badge status-active"
      : status === "draft"
        ? "status-badge"
        : "status-badge status-inactive";
  return <span className={cls}>{status}</span>;
}

export default function EventsPage() {
  const qc = useQueryClient();
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Event | null>(null);
  const [deleting, setDeleting] = useState<Event | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["events"],
    queryFn: async () => {
      const res = await apiClient.get("/events", { params: { per_page: 100 } });
      return (res.data.data ?? []) as Event[];
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => apiClient.delete(`/events/${id}`),
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["events"] });
      setDeleting(null);
    },
  });

  const publishMutation = useMutation({
    mutationFn: async (id: number) => apiClient.post(`/events/${id}/publish`),
    onSuccess: async () => qc.invalidateQueries({ queryKey: ["events"] }),
  });

  const unpublishMutation = useMutation({
    mutationFn: async (id: number) => apiClient.post(`/events/${id}/unpublish`),
    onSuccess: async () => qc.invalidateQueries({ queryKey: ["events"] }),
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Event Management"
        description="Create and publish company events for supervisors"
        action={
          <Button
            onClick={() => {
              setEditing(null);
              setFormOpen(true);
            }}
          >
            <Plus className="h-4 w-4" />
            Add event
          </Button>
        }
      />

      <DataTable<Event>
        loading={isLoading}
        data={data ?? []}
        emptyMessage="No events yet."
        columns={[
          { key: "title", header: "Title" },
          { key: "location", header: "Location", render: (r) => r.location ?? "—" },
          {
            key: "start_date",
            header: "Start",
            render: (r) => new Date(r.start_date).toLocaleString(),
          },
          {
            key: "status",
            header: "Status",
            render: (r) => <StatusBadge status={r.status} />,
          },
          {
            key: "actions",
            header: "",
            render: (r) => (
              <div className="flex gap-1">
                {r.status !== "published" ? (
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => publishMutation.mutate(r.id)}
                    title="Publish"
                  >
                    <Eye className="h-4 w-4" />
                  </Button>
                ) : (
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => unpublishMutation.mutate(r.id)}
                    title="Unpublish"
                  >
                    <EyeOff className="h-4 w-4" />
                  </Button>
                )}
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => {
                    setEditing(r);
                    setFormOpen(true);
                  }}
                >
                  <Pencil className="h-4 w-4" />
                </Button>
                <Button size="sm" variant="outline" onClick={() => setDeleting(r)}>
                  <Trash2 className="h-4 w-4" />
                </Button>
              </div>
            ),
          },
        ]}
      />

      <EventFormDialog
        open={formOpen}
        event={editing}
        onClose={() => {
          setFormOpen(false);
          setEditing(null);
        }}
      />

      <ConfirmDialog
        open={!!deleting}
        title="Delete event?"
        description={`Remove "${deleting?.title}"?`}
        onConfirm={() => deleting && deleteMutation.mutate(deleting.id)}
        onCancel={() => setDeleting(null)}
      />
    </div>
  );
}
