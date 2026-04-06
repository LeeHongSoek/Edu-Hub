type UserLogPayload = {
  user_content?: string;
  score?: number;
  total_score?: number;
  score100?: number;
  time_taken?: number;
};

export const useUserLog = () => {
  const { apiBase, getAuthHeader } = useApi();
  const authToken = useCookie<string | null>("auth_token");

  const writeUserLog = async (
    logtype: string,
    objId: string | number | bigint,
    payload: UserLogPayload,
  ) => {
    if (!authToken.value) return;

    try {
      await $fetch(`${apiBase.value}/user-logs/${logtype}/${String(objId)}`, {
        method: "POST",
        headers: getAuthHeader(),
        body: payload,
      });
    } catch (error) {
      console.warn("[user-log] failed:", logtype, objId, payload, error);
    }
  };

  const writeUserLogOncePerSession = async (
    sessionKey: string,
    logtype: string,
    objId: string | number | bigint,
    payload: UserLogPayload,
  ) => {
    if (typeof window === "undefined") return;
    if (sessionStorage.getItem(sessionKey)) return;
    await writeUserLog(logtype, objId, payload);
    sessionStorage.setItem(sessionKey, "1");
  };

  return {
    writeUserLog,
    writeUserLogOncePerSession,
  };
};
