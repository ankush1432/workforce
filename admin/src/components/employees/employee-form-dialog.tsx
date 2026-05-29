"use client";

import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { useDefaultCompany } from "@/lib/hooks/use-default-company";
import { selectClassName } from "@/lib/form-styles";
import type { Employee, Site } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

interface EmployeeFormDialogProps {
  open: boolean;
  employee?: Employee | null;
  onClose: () => void;
}

const empty = {
  site_id: "",
  employee_code: "",
  first_name: "",
  last_name: "",
  email: "",
  phone: "",
  department: "",
  designation: "",
  is_active: true,
};

export function EmployeeFormDialog({ open, employee, onClose }: EmployeeFormDialogProps) {
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
    if (employee) {
      setForm({
        site_id: String(employee.site_id),
        employee_code: employee.employee_code,
        first_name: employee.first_name,
        last_name: employee.last_name,
        email: employee.email ?? "",
        phone: employee.phone ?? "",
        department: employee.department ?? "",
        designation: employee.designation ?? "",
        is_active: employee.is_active,
      });
    } else {
      setForm(empty);
    }
  }, [open, employee]);

  const mutation = useMutation({
    mutationFn: async () => {
      if (!company) throw new Error("Company not configured");
      const payload = {
        company_id: company.id,
        site_id: Number(form.site_id),
        employee_code: form.employee_code,
        first_name: form.first_name,
        last_name: form.last_name,
        email: form.email || null,
        phone: form.phone || null,
        department: form.department || null,
        designation: form.designation || null,
        is_active: form.is_active,
      };
      if (employee) {
        await apiClient.put(`/employees/${employee.id}`, payload);
      } else {
        await apiClient.post("/employees", payload);
      }
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["employees"] });
      onClose();
    },
  });

  if (!open) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-panel max-h-[90vh] w-full max-w-lg overflow-y-auto">
        <h3 className="text-lg font-semibold text-slate-900">
          {employee ? "Edit Employee" : "Add Employee"}
        </h3>
        <form
          className="mt-5 space-y-4"
          onSubmit={(e) => {
            e.preventDefault();
            mutation.mutate();
          }}
        >
          <div>
            <label className="form-label">Work location</label>
            <select
              className={selectClassName}
              value={form.site_id}
              onChange={(e) => setForm({ ...form, site_id: e.target.value })}
              required
            >
              <option value="">Select location</option>
              {sites.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="form-label">Employee code</label>
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
            />
          </div>
          <div>
            <label className="form-label">Phone</label>
            <Input
              value={form.phone}
              onChange={(e) => setForm({ ...form, phone: e.target.value })}
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="form-label">Department</label>
              <Input
                value={form.department}
                onChange={(e) => setForm({ ...form, department: e.target.value })}
              />
            </div>
            <div>
              <label className="form-label">Designation</label>
              <Input
                value={form.designation}
                onChange={(e) => setForm({ ...form, designation: e.target.value })}
              />
            </div>
          </div>
          <label className="flex items-center gap-2 text-sm text-slate-700">
            <input
              type="checkbox"
              className="rounded border-slate-300"
              checked={form.is_active}
              onChange={(e) => setForm({ ...form, is_active: e.target.checked })}
            />
            Active employee
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
