import { basename, resolve } from 'path';

export function getApiRequestLogPath() {
  const cwd = process.cwd();
  const logDir = basename(cwd) === '_NuxtJs'
    ? resolve(cwd, '..', 'logs')
    : resolve(cwd, 'logs');

  return {
    logDir,
    logPath: resolve(logDir, 'api-requests.log'),
  };
}
