import { getRequestHost, getRequestIP, getRequestProtocol, getRequestURL, proxyRequest } from 'h3';

const ADMIN_API_ORIGIN = 'http://127.0.0.1:4000';

export default defineEventHandler((event) => {
  const requestUrl = getRequestURL(event);
  const target = `${ADMIN_API_ORIGIN}${requestUrl.pathname}${requestUrl.search}`;
  const forwardedHost = getRequestHost(event, { xForwardedHost: true });
  const forwardedProto = getRequestProtocol(event, { xForwardedProto: true });
  const forwardedFor = getRequestIP(event, { xForwardedFor: true });

  return proxyRequest(event, target, {
    headers: {
      host: forwardedHost,
      'x-forwarded-host': forwardedHost,
      'x-forwarded-proto': forwardedProto,
      ...(forwardedFor ? { 'x-forwarded-for': forwardedFor } : {}),
    },
  });
});
