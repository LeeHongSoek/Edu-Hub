export default defineNuxtRouteMiddleware(() => {
  const authToken = useCookie<string | null>("auth_token");
  const userInfo = useCookie<string | null>("user_info");

  if (authToken.value && userInfo.value) return;

  return navigateTo("/");
});
