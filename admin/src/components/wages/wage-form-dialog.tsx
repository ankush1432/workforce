"use client";

import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { useDefaultCompany } from "@/lib/hooks/use-default-company";
import { selectClassName } from "@/lib/form-styles";
import type { Employee, Supervisor, Wage } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

interface WageFormDialogProps {
  open: boolean;
  wage?: Wage | null;
  onClose: () => void;
}

const MONTHS = [
  { value: 1, label: "January" },
  { value: 2, label: "February" },
  { value: 3, label: "March" },
  { value: 4, label: "April" },
  { value: 5, label: "May" },
  { value: 6, label: "June" },
  { value: 7, label: "July" },
  { value: 8, label: "August" },
  { value: 9, label: "September" },
  { value: 10, label: "October" },
  { value: 11, label: "November" },
  { value: 12, label: "December" },
];

const empty = {
  supervisor_id: "",
  employee_id: "",
  year: String(new Date().getFullYear()),
  month: String(new Date().getMonth() + 1),
  hourly_rate: "",
  daily_rate: "",
  days_worked: "",
  hours_worked: "",
  gross_amount: "",
  deductions: "",
  net_amount: "",
  status: "draft" as Wage["status"],
};

function numOrNull(v: string): number | null {
  if (v === "" || v == null) return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

export function WageFormDialog({ open, wage, onClose }: WageFormDialogProps) {
  const qc = useQueryClient();
  const [form, setForm] = useState(empty);
  const { data: company, isLoading: companyLoading } = useDefaultCompany(open);

  const { data: supervisors = [] } = useQuery({
    queryKey: ["supervisors"],
    queryFn: async () => {
      const res = await apiClient.get("/supervisors", { params: { per_page: 100 } });
      return (res.data.data ?? []) as Supervisor[];
    },
    enabled: open,
  });

  const { data: allEmployees = [] } = useQuery({
    queryKey: ["employees", "wage-form"],
    queryFn: async () => {
      const res = await apiClient.get("/employees", { params: { per_page: 200, is_active: 1 } });
      return (res.data.data ?? []) as Employee[];
    },
    enabled: open,
  });

  const employees = useMemo(() => {
    if (!form.supervisor_id) return allEmployees;
    const sup = supervisors.find((s) => String(s.id) === form.supervisor_id);
    if (!sup?.site_id) return allEmployees;
    return allEmployees.filter((e) => e.site_id === sup.site_id);
  }, [allEmployees, form.supervisor_id, supervisors]);

  useEffect(() => {
    if (!open) return;
    if (wage) {
      setForm({
        supervisor_id: "",
        employee_id: String(wage.employee_id),
        year: String(wage.year),
        month: String(wage.month),
        hourly_rate: wage.hourly_rate != null ? String(wage.hourly_rate) : "",
        daily_rate: wage.daily_rate != null ? String(wage.daily_rate) : "",
        days_worked: wage.days_worked != null ? String(wage.days_worked) : "",
        hours_worked: wage.hours_worked != null ? String(wage.hours_worked) : "",
        gross_amount: wage.gross_amount != null ? String(wage.gross_amount) : "",
        deductions: wage.deductions != null ? String(wage.deductions) : "",
        net_amount: wage.net_amount != null ? String(wage.net_amount) : "",
        status: wage.status,
      });
    } else {
      setForm(empty);
    }
  }, [open, wage]);

  const recalcNet = (next: typeof form) => {
    const gross = numOrNull(next.gross_amount) ?? 0;
    const ded = numOrNull(next.deductions) ?? 0;
    return { ...next, net_amount: String(Math.max(0, gross - ded)) };
  };

  const mutation = useMutation({
    mutationFn: async () => {
      if (!company) throw new Error("Company not loaded");
      const payload = {
        hourly_rate: numOrNull(form.hourly_rate),
        daily_rate: numOrNull(form.daily_rate),
        days_worked: numOrNull(form.days_worked),
        hours_worked: numOrNull(form.hours_worked),
        gross_amount: numOrNull(form.gross_amount),
        deductions: numOrNull(form.deductions),
        net_amount: numOrNull(form.net_amount),
        status: form.status,
      };
      if (wage) {
        await apiClient.put(`/wages/${wage.id}`, payload);
      } else {
        if (!form.employee_id) throw new Error("Employee required");
        await apiClient.post("/wages", {
          ...payload,
          company_id: company.id,
          employee_id: Number(form.employee_id),
          year: Number(form.year),
          month: Number(form.month),
        });
      }
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["wages"] });
      onClose();
    },
  });

  if (!open) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-panel max-h-[90vh] w-full max-w-lg overflow-y-auto">
        <h3 className="text-lg font-semibold text-slate-900">
          {wage ? "Edit Wage Record" : "Add Wage Record"}
        </h3>
        <form
          className="mt-5 space-y-4"
          onSubmit={(e) => {
            e.preventDefault();
            mutation.mutate();
          }}
        >
          {!wage && (
            <>
              <div>
                <label className="form-label">Supervisor (filter employees)</label>
                <select
                  className={selectClassName}
                  value={form.supervisor_id}
                  onChange={(e) =>
                    setForm({ ...form, supervisor_id: e.target.value, employee_id: "" })
                  }
                >
                  <option value="">All supervisors</option>
                  {supervisors.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.full_name ?? `${s.first_name} ${s.last_name}`}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="form-label">Employee</label>
                <select
                  className={selectClassName}
                  value={form.employee_id}
                  onChange={(e) => setForm({ ...form, employee_id: e.target.value })}
                  required
                >
                  <option value="">Select employee</option>
                  {employees.map((e) => (
                    <option key={e.id} value={e.id}>
                      {e.full_name ?? `${e.first_name} ${e.last_name}`} ({e.employee_code})
                    </option>
                  ))}
                </select>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="form-label">Year</label>
                  <Input
                    type="number"
                    min={2000}
                    max={2100}
                    value={form.year}
                    onChange={(e) => setForm({ ...form, year: e.target.value })}
                    required
                  />
                </div>
                <div>
                  <label className="form-label">Month</label>
                  <select
                    className={selectClassName}
                    value={form.month}
                    onChange={(e) => setForm({ ...form, month: e.target.value })}
                    required
                  >
                    {MONTHS.map((m) => (
                      <option key={m.value} value={m.value}>
                        {m.label}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </>
          )}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="form-label">Hourly rate</label>
              <Input
                type="number"
                step="0.01"
                value={form.hourly_rate}
                onChange={(e) => setForm({ ...form, hourly_rate: e.target.value })}
              />
            </div>
            <div>
              <label className="form-label">Daily rate</label>
              <Input
                type="number"
                step="0.01"
                value={form.daily_rate}
                onChange={(e) => setForm({ ...form, daily_rate: e.target.value })}
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="form-label">Days worked</label>
              <Input
                type="number"
                min={0}
                value={form.days_worked}
                onChange={(e) => setForm({ ...form, days_worked: e.target.value })}
              />
            </div>
            <div>
              <label className="form-label">Hours worked</label>
              <Input
                type="number"
                min={0}
                value={form.hours_worked}
                onChange={(e) => setForm({ ...form, hours_worked: e.target.value })}
              />
            </div>
          </div>
          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="form-label">Gross</label>
              <Input
                type="number"
                step="0.01"
                value={form.gross_amount}
                onChange={(e) => setForm(recalcNet({ ...form, gross_amount: e.target.value }))}
              />
            </div>
            <div>
              <label className="form-label">Deductions</label>
              <Input
                type="number"
                step="0.01"
                value={form.deductions}
                onChange={(e) => setForm(recalcNet({ ...form, deductions: e.target.value }))}
              />
            </div>
            <div>
              <label className="form-label">Net</label>
              <Input
                type="number"
                step="0.01"
                value={form.net_amount}
                onChange={(e) => setForm({ ...form, net_amount: e.target.value })}
              />
            </div>
          </div>
          <div>
            <label className="form-label">Status</label>
            <select
              className={selectClassName}
              value={form.status}
              onChange={(e) =>
                setForm({ ...form, status: e.target.value as Wage["status"] })
              }
            >
              <option value="draft">Draft</option>
              <option value="approved">Approved</option>
              <option value="paid">Paid</option>
            </select>
          </div>
          {mutation.isError && (
            <p className="text-sm text-red-600">
              Could not save wage. Check employee, period, and amounts.
            </p>
          )}
          <div className="flex justify-end gap-2 border-t border-slate-200 pt-4">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={mutation.isPending || companyLoading || !company}>
              {mutation.isPending ? "Saving…" : "Save wage"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
