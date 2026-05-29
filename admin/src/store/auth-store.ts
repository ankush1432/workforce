import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { User } from "@/lib/api/types";
import { clearAuthCookie, clearClientSession, setAuthCookie } from "@/lib/auth/session";

interface AuthState {
  token: string | null;
  user: User | null;
  setAuth: (token: string, user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      setAuth: (token, user) => {
        localStorage.setItem("auth_token", token);
        setAuthCookie(token);
        set({ token, user });
      },
      logout: () => {
        clearClientSession();
        set({ token: null, user: null });
      },
    }),
    { name: "face-attendance-auth" }
  )
);
