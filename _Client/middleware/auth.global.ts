export default defineNuxtRouteMiddleware((to) => {
  // 로그인/랜딩 페이지는 공개
  if (to.path === "/") return;

  const authToken = useCookie<string | null>("auth_token");
  const userInfo = useCookie<string | null>("user_info");

  if (authToken.value && userInfo.value) {
    if (import.meta.client) {
      sessionStorage.removeItem("auth_required_alert_shown");
    }
    return;
  }

  if (import.meta.client) {
    const alreadyShown = sessionStorage.getItem("auth_required_alert_shown");
    if (!alreadyShown) {
      window.alert("로그인이 필요합니다. 먼저 로그인해 주세요.");
      sessionStorage.setItem("auth_required_alert_shown", "1");
    }
  }

  return navigateTo("/");
});
