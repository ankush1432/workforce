"use client";

import { useEffect, useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { useDefaultCompany } from "@/lib/hooks/use-default-company";
import type { Site } from "@/lib/api/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { selectClassName } from "@/lib/form-styles";

interface SiteFormDialogProps {
  open: boolean;
  site?: Site | null;
  onClose: () => void;
}

const empty = {
  code: "",
  name: "",
  address: "",
  latitude: "",
  longitude: "",
  geofence_radius_m: "100",
  is_active: true,
};

export function SiteFormDialog({ open, site, onClose }: SiteFormDialogProps) {
  const qc = useQueryClient();
  const [form, setForm] = useState(empty);
  const { data: company, isLoading: companyLoading } = useDefaultCompany(open);

  useEffect(() => {
    if (!open) return;
    if (site) {
      setForm({
        code: site.code,
        name: site.name,
        address: site.address ?? "",
        latitude: site.latitude != null ? String(site.latitude) : "",
        longitude: site.longitude != null ? String(site.longitude) : "",
        geofence_radius_m: site.geofence_radius_m != null ? String(site.geofence_radius_m) : "100",
        is_active: site.is_active,
      });
    } else {
      setForm(empty);
    }
  }, [open, site]);

  const mutation = useMutation({
    mutationFn: async () => {
      if (!company) throw new Error("Company not loaded");
      const payload = {
        company_id: company.id,
        code: form.code,
        name: form.name,
        address: form.address || null,
        latitude: form.latitude ? Number(form.latitude) : null,
        longitude: form.longitude ? Number(form.longitude) : null,
        geofence_radius_m: form.geofence_radius_m ? Number(form.geofence_radius_m) : 100,
        is_active: form.is_active,
      };
      if (site) {
        await apiClient.put(`/sites/${site.id}`, payload);
      } else {
        await apiClient.post("/sites", payload);
      }
    },
    onSuccess: async () => {
      await qc.invalidateQueries({ queryKey: ["sites"] });
      onClose();
    },
  });

  if (!open) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-panel max-h-[90vh] w-full max-w-lg overflow-y-auto">
        <h3 className="text-lg font-semibold text-slate-900">
          {site ? "Edit Location" : "Add Location"}
        </h3>
        <p className="mt-1 text-sm text-slate-500">
          {company ? company.name : "Loading organization…"}
        </p>
        <form
          className="mt-5 space-y-4"
          onSubmit={(e) => {
            e.preventDefault();
            mutation.mutate();
          }}
        >
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="form-label">Location code</label>
              <Input
                placeholder="e.g. HQ-01"
                value={form.code}
                onChange={(e) => setForm({ ...form, code: e.target.value })}
                required
                disabled={!!site}
              />
            </div>
            <div>
              <label className="form-label">Name</label>
              <Input
                placeholder="Head office"
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                required
              />
            </div>
          </div>
          <div>
            <label className="form-label">Address</label>
            <Input
              placeholder="Street, city, state"
              value={form.address}
              onChange={(e) => setForm({ ...form, address: e.target.value })}
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="form-label">Latitude</label>
              <Input
                type="number"
                step="any"
                placeholder="Optional"
                value={form.latitude}
                onChange={(e) => setForm({ ...form, latitude: e.target.value })}
              />
            </div>
            <div>
              <label className="form-label">Longitude</label>
              <Input
                type="number"
                step="any"
                placeholder="Optional"
                value={form.longitude}
                onChange={(e) => setForm({ ...form, longitude: e.target.value })}
              />
            </div>
          </div>
          <div>
            <label className="form-label">Geofence radius (meters)</label>
            <Input
              type="number"
              min={10}
              value={form.geofence_radius_m}
              onChange={(e) => setForm({ ...form, geofence_radius_m: e.target.value })}
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
            <p className="text-sm text-red-600">Could not save location. Check all required fields.</p>
          )}
          <div className="flex justify-end gap-2 border-t border-slate-200 pt-4">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={mutation.isPending || companyLoading || !company}>
              {mutation.isPending ? "Saving…" : "Save location"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
