"use client";

import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import type { Company } from "@/lib/api/types";

/** Single-tenant setup: uses the first (and only) company record. */
export function useDefaultCompany(enabled = true) {
  return useQuery({
    queryKey: ["default-company"],
    queryFn: async () => {
      const res = await apiClient.get("/companies");
      const companies = (res.data.data ?? []) as Company[];
      if (!companies.length) {
        throw new Error("No company configured. Run database seeders.");
      }
      return companies[0];
    },
    enabled,
    staleTime: 5 * 60 * 1000,
  });
}
