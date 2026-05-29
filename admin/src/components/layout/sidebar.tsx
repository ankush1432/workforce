"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  Users,
  MapPin,
  UserCog,
  ScanFace,
  CalendarCheck,
  CalendarDays,
  Clock,
  Wallet,
  BarChart3,
  Bell,
  Settings,
  LayoutDashboard,
  LogOut,
  Building2,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuthStore } from "@/store/auth-store";
import { apiClient } from "@/lib/api/client";

const nav = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/sites", label: "Locations", icon: MapPin },
  { href: "/supervisors", label: "Supervisors", icon: UserCog },
  { href: "/employees", label: "Employees", icon: Users },
  { href: "/events", label: "Events", icon: CalendarDays },
  { href: "/face-registrations", label: "Face Registration", icon: ScanFace },
  { href: "/attendance", label: "Attendance", icon: CalendarCheck },
  { href: "/shifts", label: "Shifts", icon: Clock },
  { href: "/wages", label: "Wages", icon: Wallet },
  { href: "/reports", label: "Reports", icon: BarChart3 },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/settings", label: "Settings", icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const logout = useAuthStore((s) => s.logout);

  const handleSignOut = async () => {
    try {
      await apiClient.post("/auth/logout");
    } catch {
      // ignore — local session cleared regardless
    }

    logout();

    router.replace("/login");
  };

  return (
    <aside className="flex h-screen w-64 flex-col border-r border-slate-800 bg-slate-900 text-white">
      <div className="border-b border-slate-800 px-5 py-6">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-700">
            <Building2 className="h-5 w-5 text-white" />
          </div>
          <div>
            <p className="text-xs font-medium uppercase tracking-wider text-slate-400">Workforce</p>
            <h1 className="text-base font-semibold leading-tight">Attendance Admin</h1>
          </div>
        </div>
      </div>
      <nav className="flex-1 space-y-0.5 overflow-y-auto px-3 py-4">
        {nav.map((item) => {
          const Icon = item.icon;
          const active = pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition",
                active
                  ? "bg-blue-800 text-white"
                  : "text-slate-300 hover:bg-slate-800 hover:text-white"
              )}
            >
              <Icon className="h-4 w-4 shrink-0 opacity-90" />
              {item.label}
            </Link>
          );
        })}
      </nav>
      <div className="border-t border-slate-800 p-3">
        <button
          type="button"
          onClick={handleSignOut}
          className="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-slate-300 transition hover:bg-slate-800 hover:text-white"
        >
          <LogOut className="h-4 w-4" />
          Sign out
        </button>
      </div>
    </aside>
  );
}
