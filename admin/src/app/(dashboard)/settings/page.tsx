"use client";

import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <h1 className="page-title">Settings</h1>
      <Card>
        <CardHeader>
          <CardTitle>API Configuration</CardTitle>
          <CardDescription>Environment settings for integrations</CardDescription>
        </CardHeader>
        <div className="space-y-4">
          <div>
            <label className="mb-1.5 block text-sm text-slate-400">API Base URL</label>
            <Input defaultValue={process.env.NEXT_PUBLIC_API_URL ?? "https://wages.aarvedsol.com/api/v1"} readOnly />
          </div>
          <div>
            <label className="mb-1.5 block text-sm text-slate-400">Face Match Threshold</label>
            <Input defaultValue="0.75" />
          </div>
          <Button>Save Settings</Button>
        </div>
      </Card>
    </div>
  );
}
