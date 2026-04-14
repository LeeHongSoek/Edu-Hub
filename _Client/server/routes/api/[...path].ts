import { getRequestHost, getRequestIP, getRequestProtocol, getRequestURL, proxyRequest } from 'h3';

export default defineEventHandler((event) => {
  const { backendOrigin } = useRuntimeConfig(event);
  const requestUrl = getRequestURL(event, {
    xForwardedHost: true,
    xForwardedProto: true,
  });
  const target = `${backendOrigin}${requestUrl.pathname}${requestUrl.search}`;
  const forwardedHost = getRequestHost(event, { xForwardedHost: true });
  const forwardedProto = getRequestProtocol(event, { xForwardedProto: true });
  const forwardedFor = getRequestIP(event, { xForwardedFor: true });

  return proxyRequest(event, target, {
    headers: {
      'x-forwarded-host': forwardedHost,
      'x-forwarded-proto': forwardedProto,
      ...(forwardedFor ? { 'x-forwarded-for': forwardedFor } : {}),
    },
  });
});
