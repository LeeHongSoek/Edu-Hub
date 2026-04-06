let sessionExpiryTimer: ReturnType<typeof setTimeout> | null = null;

const decodeJwtPayload = (token: string) => {
  try {
    const [, payload] = token.split(".");
    if (!payload) return null;
    const normalized = payload.replace(/-/g, "+").replace(/_/g, "/");
    const padded = normalized.padEnd(
      normalized.length + ((4 - (normalized.length % 4)) % 4),
      "=",
    );
    return JSON.parse(atob(padded));
  } catch {
    return null;
  }
};

export const useAuthSession = () => {
  const authToken = useCookie<string | null>("auth_token");
  const userCookie = useCookie<string | null>("user_info");
  const { apiBase } = useApi();

  const writeLogoutLog = async (
    reason: "manual" | "expired" | "invalid",
  ) => {
    if (!authToken.value || !userCookie.value) return;

    try {
      await $fetch(`${apiBase.value}/auth/logout`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${authToken.value}`,
        },
        body: {
          reason,
        },
      });
    } catch {
      // logout logging should not block session cleanup
    }
  };

  const clearSession = async (
    reason: "manual" | "expired" | "invalid" = "manual",
  ) => {
    await writeLogoutLog(reason);
    authToken.value = null;
    userCookie.value = null;

    if (typeof window !== "undefined") {
      sessionStorage.setItem("auth_logout_reason", reason);
    }

    await navigateTo("/");
  };

  const stopSessionWatcher = () => {
    if (sessionExpiryTimer) {
      clearTimeout(sessionExpiryTimer);
      sessionExpiryTimer = null;
    }
  };

  const startSessionWatcher = () => {
    if (typeof window === "undefined") return;

    stopSessionWatcher();

    if (!authToken.value) return;

    const payload = decodeJwtPayload(authToken.value);
    const expiresAt = Number(payload?.exp ?? 0) * 1000;

    if (!expiresAt) return;

    const remainingMs = expiresAt - Date.now();

    if (remainingMs <= 0) {
      void clearSession("expired");
      return;
    }

    sessionExpiryTimer = setTimeout(() => {
      void clearSession("expired");
    }, remainingMs);
  };

  return {
    clearSession,
    startSessionWatcher,
    stopSessionWatcher,
  };
};
