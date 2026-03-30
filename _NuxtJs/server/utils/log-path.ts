import { basename, resolve } from 'path';

export function getApiRequestLogPath(fileName = 'api-front.log') {
  const cwd = process.cwd();
  const logDir = basename(cwd) === '_NuxtJs'
    ? resolve(cwd, '..', 'logs')
    : resolve(cwd, 'logs');

  return {
    logDir,
    logPath: resolve(logDir, fileName),
  };
}
