"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Sidebar } from "@/components/layout/sidebar";
import { useAuthStore } from "@/store/auth-store";

function hasAuthCookie(): boolean {
  if (typeof document === "undefined") return false;
  return document.cookie.split(";").some((c) => {
    const part = c.trim();
    if (!part.startsWith("auth_token=")) return false;
    const value = part.slice("auth_token=".length).trim();
    return value.length > 0;
  });
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const token = useAuthStore((s) => s.token);

  useEffect(() => {
    const stored = localStorage.getItem("auth_token");
    const cookie = hasAuthCookie();
    if (!token && !stored && !cookie) {
      router.replace("/login");
    }
  }, [token, router]);

  return (
    <div className="flex min-h-screen bg-slate-100">
      <Sidebar />
      <main className="flex-1 overflow-y-auto">
        <div className="mx-auto max-w-7xl p-8">{children}</div>
      </main>
    </div>
  );
}
