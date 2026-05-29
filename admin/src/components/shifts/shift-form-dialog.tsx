"use client";

import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { useDefaultCompany } from "@/lib/hooks/use-default-company";
import { selectClassName } from "@/lib/form-styles";
import type { Shift, Site } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

interface ShiftFormDialogProps {
  open: boolean;
  shift?: Shift | null;
  onClose: () => void;
}

const empty = {
  site_id: "",
  name: "",
  start_time: "09:00",
  end_time: "18:00",
  grace_minutes: "15",
  is_active: true,
};

function toTimeInput(value: string): string {
  if (!value) return "";
  return value.length >= 5 ? value.slice(0, 5) : value;
}

export function ShiftFormDialog({ open, shift, onClose }: ShiftFormDialogProps) {
  const qc = useQueryClient();
  const [form, setForm] = useState(empty);
  const { data: company, isLoading: companyLoading } = useDefaultCompany(open);

  const { data: sites = [] } = useQuery({
    queryKey: ["sites"],
    queryFn: async () => (await apiClient.get("/sites")).data.data as Site[],
    enabled: open,
  });

  useEffect(() => {
    if (!open) return;
    if (shift) {
      setForm({
        site_id: shift.site_id ? String(shift.site_id) : "",
        name: shift.name,
        start_time: toTimeInput(shift.start_time),
        end_time: toTimeInput(shift.end_time),
        grace_minutes: String(shift.grace_minutes ?? 15),
        is_active: shift.is_active,
      });
    } else {
      setForm(empty);
    }
  }, [open, shift]);

  const mutation = useMutation({
    mutationFn: async () => {
      if (!company) throw new Error("Company not loaded");
      const payload = {
        company_id: company.id,
        site_id: form.site_id ? Number(form.site_id) : null,
        name: form.name,
        start_time: form.start_time,
        end_time: form.end_time,
        grace_minutes: Number(form.grace_minutes) || 15,
        is_active: form.is_active,
      };
      if (shift) {
        const { company_id: _, site_id: __, ...updatePayload } = payload;
        await apiClient.put(`/shifts/${shift.id}`, updatePayload);
      } else {
        await apiClient.post("/shifts", payload);
      }
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["shifts"] });
      onClose();
    },
  });

  if (!open) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-panel max-h-[90vh] w-full max-w-lg overflow-y-auto">
        <h3 className="text-lg font-semibold text-slate-900">
          {shift ? "Edit Shift" : "Add Shift"}
        </h3>
        <form
          className="mt-5 space-y-4"
          onSubmit={(e) => {
            e.preventDefault();
            mutation.mutate();
          }}
        >
          {!shift && (
            <div>
              <label className="form-label">Location (optional)</label>
              <select
                className={selectClassName}
                value={form.site_id}
                onChange={(e) => setForm({ ...form, site_id: e.target.value })}
              >
                <option value="">All locations</option>
                {sites.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
              </select>
            </div>
          )}
          <div>
            <label className="form-label">Shift name</label>
            <Input
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              placeholder="Morning shift"
              required
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="form-label">Start time</label>
              <Input
                type="time"
                value={form.start_time}
                onChange={(e) => setForm({ ...form, start_time: e.target.value })}
                required
              />
            </div>
            <div>
              <label className="form-label">End time</label>
              <Input
                type="time"
                value={form.end_time}
                onChange={(e) => setForm({ ...form, end_time: e.target.value })}
                required
              />
            </div>
          </div>
          <div>
            <label className="form-label">Grace minutes</label>
            <Input
              type="number"
              min={0}
              value={form.grace_minutes}
              onChange={(e) => setForm({ ...form, grace_minutes: e.target.value })}
            />
          </div>
          <div>
            <label className="form-label">Status</label>
            <select
              className={selectClassName}
              value={form.is_active ? "1" : "0"}
              onChange={(e) => setForm({ ...form, is_active: e.target.value === "1" })}
            >
              <option value="1">Active</option>
              <option value="0">Inactive</option>
            </select>
          </div>
          {mutation.isError && (
            <p className="text-sm text-red-600">Could not save shift. Check required fields.</p>
          )}
          <div className="flex justify-end gap-2 border-t border-slate-200 pt-4">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={mutation.isPending || companyLoading || !company}>
              {mutation.isPending ? "Saving…" : "Save shift"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
