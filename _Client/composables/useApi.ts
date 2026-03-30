export const useApi = () => {
  const config = useRuntimeConfig();
  const token = useCookie('auth_token');

  const apiBase = computed(() => config.public.apiBase);

  return {
    apiBase,
    token: computed(() => token.value),
    getAuthHeader: () => ({
      Authorization: `Bearer ${token.value}`
    })
  };
};
