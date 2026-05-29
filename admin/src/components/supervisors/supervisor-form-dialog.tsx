"use client";

import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { useDefaultCompany } from "@/lib/hooks/use-default-company";
import { selectClassName } from "@/lib/form-styles";
import type { Site, Supervisor } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

interface SupervisorFormDialogProps {
  open: boolean;
  supervisor?: Supervisor | null;
  onClose: () => void;
}

const empty = {
  site_id: "",
  employee_code: "",
  first_name: "",
  last_name: "",
  email: "",
  phone: "",
  password: "",
  is_active: true,
};

export function SupervisorFormDialog({ open, supervisor, onClose }: SupervisorFormDialogProps) {
  const qc = useQueryClient();
  const [form, setForm] = useState(empty);
  const { data: company } = useDefaultCompany(open);

  const { data: sites = [] } = useQuery({
    queryKey: ["sites"],
    queryFn: async () => (await apiClient.get("/sites")).data.data as Site[],
    enabled: open,
  });

  useEffect(() => {
    if (!open) return;
    if (supervisor) {
      setForm({
        site_id: supervisor.site_id ? String(supervisor.site_id) : "",
        employee_code: supervisor.employee_code,
        first_name: supervisor.first_name,
        last_name: supervisor.last_name,
        email: supervisor.email,
        phone: supervisor.phone ?? "",
        password: "",
        is_active: supervisor.is_active,
      });
    } else {
      setForm(empty);
    }
  }, [open, supervisor]);

  const mutation = useMutation({
    mutationFn: async () => {
      if (!company) throw new Error("Company not configured");
      const payload: Record<string, unknown> = {
        company_id: company.id,
        site_id: form.site_id ? Number(form.site_id) : null,
        employee_code: form.employee_code,
        first_name: form.first_name,
        last_name: form.last_name,
        email: form.email,
        phone: form.phone || null,
        is_active: form.is_active,
      };
      if (!supervisor && form.password) {
        payload.password = form.password;
      }
      if (supervisor && form.password) {
        payload.password = form.password;
      }
      if (supervisor) {
        await apiClient.put(`/supervisors/${supervisor.id}`, payload);
      } else {
        if (!form.password) throw new Error("Password required");
        await apiClient.post("/supervisors", payload);
      }
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["supervisors"] });
      onClose();
    },
  });

  if (!open) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-panel max-h-[90vh] w-full max-w-lg overflow-y-auto">
        <h3 className="text-lg font-semibold text-slate-900">
          {supervisor ? "Edit Supervisor" : "Add Supervisor"}
        </h3>
        <form
          className="mt-5 space-y-4"
          onSubmit={(e) => {
            e.preventDefault();
            mutation.mutate();
          }}
        >
          <div>
            <label className="form-label">Assigned location</label>
            <select
              className={selectClassName}
              value={form.site_id}
              onChange={(e) => setForm({ ...form, site_id: e.target.value })}
            >
              <option value="">All locations (optional)</option>
              {sites.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="form-label">Supervisor code</label>
            <Input
              value={form.employee_code}
              onChange={(e) => setForm({ ...form, employee_code: e.target.value })}
              required
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="form-label">First name</label>
              <Input
                value={form.first_name}
                onChange={(e) => setForm({ ...form, first_name: e.target.value })}
                required
              />
            </div>
            <div>
              <label className="form-label">Last name</label>
              <Input
                value={form.last_name}
                onChange={(e) => setForm({ ...form, last_name: e.target.value })}
                required
              />
            </div>
          </div>
          <div>
            <label className="form-label">Email</label>
            <Input
              type="email"
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
              required
            />
          </div>
          <div>
            <label className="form-label">Phone</label>
            <Input
              value={form.phone}
              onChange={(e) => setForm({ ...form, phone: e.target.value })}
            />
          </div>
          <div>
            <label className="form-label">Password</label>
            <Input
              type="password"
              placeholder={supervisor ? "Leave blank to keep current" : "Required for new account"}
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
              required={!supervisor}
            />
          </div>
          <label className="flex items-center gap-2 text-sm text-slate-700">
            <input
              type="checkbox"
              className="rounded border-slate-300"
              checked={form.is_active}
              onChange={(e) => setForm({ ...form, is_active: e.target.checked })}
            />
            Active account
          </label>
          {mutation.isError && (
            <p className="text-sm text-red-600">Save failed. Check required fields.</p>
          )}
          <div className="flex justify-end gap-2 border-t border-slate-200 pt-4">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={mutation.isPending || !company}>
              {mutation.isPending ? "Saving…" : "Save"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
