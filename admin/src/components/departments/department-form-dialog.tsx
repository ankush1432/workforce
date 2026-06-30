"use client";

import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { useDefaultCompany } from "@/lib/hooks/use-default-company";
import { selectClassName } from "@/lib/form-styles";
import type { Department } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

interface DepartmentFormDialogProps {
  open: boolean;
  department?: Department | null;
  onClose: () => void;
}

const empty = {
  name: "",
  code: "",
  description: "",
  is_active: true,
};

export function DepartmentFormDialog({ open, department, onClose }: DepartmentFormDialogProps) {
  const qc = useQueryClient();
  const [form, setForm] = useState(empty);
  const { data: company, isLoading: companyLoading } = useDefaultCompany(open);

  useEffect(() => {
    if (!open) return;
    if (department) {
      setForm({
        name: department.name,
        code: department.code,
        description: department.description ?? "",
        is_active: department.is_active,
      });
    } else {
      setForm(empty);
    }
  }, [open, department]);

  const mutation = useMutation({
    mutationFn: async () => {
      if (!company) throw new Error("Company not loaded");
      const payload = {
        company_id: company.id,
        name: form.name,
        code: form.code,
        description: form.description || null,
        is_active: form.is_active,
      };
      if (department) {
        const { company_id: _, ...updatePayload } = payload;
        await apiClient.put(`/departments/${department.id}`, updatePayload);
      } else {
        await apiClient.post("/departments", payload);
      }
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["departments"] });
      onClose();
    },
  });

  if (!open) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-panel max-h-[90vh] w-full max-w-lg overflow-y-auto">
        <h3 className="text-lg font-semibold text-slate-900">
          {department ? "Edit Department" : "Add Department"}
        </h3>
        <form
          className="mt-5 space-y-4"
          onSubmit={(e) => {
            e.preventDefault();
            mutation.mutate();
          }}
        >
          <div>
            <label className="form-label">Department name</label>
            <Input
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              placeholder="Engineering"
              required
            />
          </div>
          <div>
            <label className="form-label">Code</label>
            <Input
              value={form.code}
              onChange={(e) => setForm({ ...form, code: e.target.value })}
              placeholder="ENG"
              required
            />
          </div>
          <div>
            <label className="form-label">Description</label>
            <Input
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              placeholder="Engineering department"
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
            <p className="text-sm text-red-600">Could not save department. Check required fields.</p>
          )}
          <div className="flex justify-end gap-2 border-t border-slate-200 pt-4">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={mutation.isPending || companyLoading || !company}>
              {mutation.isPending ? "Saving…" : "Save department"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
