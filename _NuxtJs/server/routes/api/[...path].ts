import { getRequestHost, getRequestIP, getRequestProtocol, getRequestURL, proxyRequest } from 'h3';

const API_ORIGIN = 'http://127.0.0.1:4000';

export default defineEventHandler((event) => {
  const requestUrl = getRequestURL(event, {
    xForwardedHost: true,
    xForwardedProto: true,
  });
  const target = `${API_ORIGIN}${requestUrl.pathname}${requestUrl.search}`;
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
