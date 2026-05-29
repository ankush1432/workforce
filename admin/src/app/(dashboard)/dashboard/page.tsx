"use client";

import { useQuery } from "@tanstack/react-query";
import { Users, UserCheck, ScanFace, MapPin, TrendingUp } from "lucide-react";
import { Area, AreaChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { apiClient } from "@/lib/api/client";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { PageHeader } from "@/components/layout/page-header";
import type { DashboardStats } from "@/lib/api/types";

export default function DashboardPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["dashboard"],
    queryFn: async () => {
      const res = await apiClient.get<{ data: DashboardStats }>("/dashboard");
      return res.data.data;
    },
  });

  const stats = [
    { label: "Employees", value: data?.employees ?? 0, icon: Users, accent: "text-blue-700 bg-blue-50" },
    { label: "Present Today", value: data?.present_today ?? 0, icon: UserCheck, accent: "text-emerald-700 bg-emerald-50" },
    { label: "Face Registered", value: data?.face_registered ?? 0, icon: ScanFace, accent: "text-violet-700 bg-violet-50" },
    { label: "Locations", value: data?.sites ?? 0, icon: MapPin, accent: "text-amber-700 bg-amber-50" },
  ];

  return (
    <div className="space-y-8">
      <PageHeader
        title="Dashboard"
        description="Workforce attendance overview for your organization"
      />

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <Card key={stat.label}>
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-sm font-medium text-slate-500">{stat.label}</p>
                  <p className="stat-value mt-1">{isLoading ? "—" : stat.value}</p>
                </div>
                <div className={`rounded-lg p-3 ${stat.accent}`}>
                  <Icon className="h-5 w-5" />
                </div>
              </div>
            </Card>
          );
        })}
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5 text-blue-800" />
              Weekly Attendance Trend
            </CardTitle>
            <CardDescription>Check-ins over the last 7 days</CardDescription>
          </CardHeader>
          <div className="h-[250px] w-full min-w-0">
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={data?.weekly_trend ?? []}>
                <defs>
                  <linearGradient id="colorCount" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#1e40af" stopOpacity={0.25} />
                    <stop offset="95%" stopColor="#1e40af" stopOpacity={0} />
                  </linearGradient>
                </defs>

                <XAxis dataKey="date" stroke="#94a3b8" fontSize={12} />
                <YAxis stroke="#94a3b8" fontSize={12} />

                <Tooltip
                  contentStyle={{
                    background: "#fff",
                    border: "1px solid #e2e8f0",
                    borderRadius: 8,
                    boxShadow: "0 4px 6px rgba(0,0,0,0.05)",
                  }}
                />

                <Area
                  type="monotone"
                  dataKey="count"
                  stroke="#1e40af"
                  fill="url(#colorCount)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Attendance Rate</CardTitle>
            <CardDescription>Today&apos;s snapshot</CardDescription>
          </CardHeader>
          <div className="flex flex-col items-center justify-center py-8">
            <div className="relative flex h-36 w-36 items-center justify-center rounded-full border-4 border-blue-100 bg-blue-50/50">
              <span className="text-4xl font-semibold text-blue-900">
                {isLoading ? "—" : `${data?.attendance_rate ?? 0}%`}
              </span>
            </div>
            <p className="mt-4 text-sm text-slate-500">
              {data?.absent_today ?? 0} absent · {data?.face_pending ?? 0} face pending
            </p>
          </div>
        </Card>
      </div>
    </div>
  );
}
