"use client";

import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { useDefaultCompany } from "@/lib/hooks/use-default-company";
import { selectClassName } from "@/lib/form-styles";
import type { Designation, Department } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

interface DesignationFormDialogProps {
  open: boolean;
  designation?: Designation | null;
  departments: Department[];
  onClose: () => void;
}

const empty = {
  department_id: "",
  title: "",
  code: "",
  description: "",
  is_active: true,
};

export function DesignationFormDialog({ open, designation, departments, onClose }: DesignationFormDialogProps) {
  const qc = useQueryClient();
  const [form, setForm] = useState(empty);
  const { data: company, isLoading: companyLoading } = useDefaultCompany(open);

  useEffect(() => {
    if (!open) return;
    if (designation) {
      setForm({
        department_id: designation.department_id ? String(designation.department_id) : "",
        title: designation.title,
        code: designation.code,
        description: designation.description ?? "",
        is_active: designation.is_active,
      });
    } else {
      setForm(empty);
    }
  }, [open, designation]);

  const mutation = useMutation({
    mutationFn: async () => {
      if (!company) throw new Error("Company not loaded");
      const payload = {
        company_id: company.id,
        department_id: form.department_id ? Number(form.department_id) : null,
        title: form.title,
        code: form.code,
        description: form.description || null,
        is_active: form.is_active,
      };
      if (designation) {
        const { company_id: _, ...updatePayload } = payload;
        await apiClient.put(`/designations/${designation.id}`, updatePayload);
      } else {
        await apiClient.post("/designations", payload);
      }
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["designations"] });
      onClose();
    },
  });

  if (!open) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-panel max-h-[90vh] w-full max-w-lg overflow-y-auto">
        <h3 className="text-lg font-semibold text-slate-900">
          {designation ? "Edit Designation" : "Add Designation"}
        </h3>
        <form
          className="mt-5 space-y-4"
          onSubmit={(e) => {
            e.preventDefault();
            mutation.mutate();
          }}
        >
          <div>
            <label className="form-label">Department (optional)</label>
            <select
              className={selectClassName}
              value={form.department_id}
              onChange={(e) => setForm({ ...form, department_id: e.target.value })}
            >
              <option value="">No department</option>
              {departments.map((d) => (
                <option key={d.id} value={d.id}>
                  {d.name}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="form-label">Title</label>
            <Input
              value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              placeholder="Software Engineer"
              required
            />
          </div>
          <div>
            <label className="form-label">Code</label>
            <Input
              value={form.code}
              onChange={(e) => setForm({ ...form, code: e.target.value })}
              placeholder="SE"
              required
            />
          </div>
          <div>
            <label className="form-label">Description</label>
            <Input
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              placeholder="Software Engineer role"
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
            <p className="text-sm text-red-600">Could not save designation. Check required fields.</p>
          )}
          <div className="flex justify-end gap-2 border-t border-slate-200 pt-4">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={mutation.isPending || companyLoading || !company}>
              {mutation.isPending ? "Saving…" : "Save designation"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
