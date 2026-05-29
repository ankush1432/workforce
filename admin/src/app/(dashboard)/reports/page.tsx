"use client";

import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function ReportsPage() {
  return (
    <div className="space-y-6">
      <h1 className="page-title">Reports & Analytics</h1>
      <div className="grid gap-4 md:grid-cols-3">
        {["Attendance Summary", "Face Registration", "Wage Report"].map((title) => (
          <Card key={title} className="cursor-pointer transition hover:border-indigo-500/30">
            <CardHeader>
              <CardTitle>{title}</CardTitle>
              <CardDescription>Export PDF / Excel</CardDescription>
            </CardHeader>
          </Card>
        ))}
      </div>
    </div>
  );
}
