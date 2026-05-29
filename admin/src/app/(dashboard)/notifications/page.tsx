"use client";

import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Bell } from "lucide-react";

export default function NotificationsPage() {
  return (
    <div className="space-y-6">
      <h1 className="page-title">Notifications</h1>
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bell className="h-5 w-5" />
            System Alerts
          </CardTitle>
          <CardDescription>Attendance anomalies and face registration updates appear here.</CardDescription>
        </CardHeader>
      </Card>
    </div>
  );
}
