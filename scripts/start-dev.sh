#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
NEST_LOG_FILE="${PROJECT_ROOT}/logs/nest-dev.log"
NUXT_DIR="${PROJECT_ROOT}/_NuxtJs"
LOG_DIR="${NUXT_DIR}/logs"
NUXT_LOG_FILE="${LOG_DIR}/nuxt-dev.log"

# 기본값은 primary.env 이고, 필요하면 다른 env 파일 경로를 첫 번째 인자로 넘길 수 있다.
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/load-runtime-env.sh" "${1:-config/runtime/primary.env}"

mkdir -p "${PROJECT_ROOT}/logs" "${LOG_DIR}"
: > "${NEST_LOG_FILE}"
: > "${NUXT_LOG_FILE}"

cleanup() {
  # 스크립트가 끝나거나 Ctrl+C 를 누르면 자식 프로세스를 모두 정리한다.
  if [[ -n "${NEST_PID:-}" ]] && kill -0 "${NEST_PID}" >/dev/null 2>&1; then
    kill "${NEST_PID}" >/dev/null 2>&1 || true
  fi

  if [[ -n "${NUXT_PID:-}" ]] && kill -0 "${NUXT_PID}" >/dev/null 2>&1; then
    kill "${NUXT_PID}" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT INT TERM

# 백엔드는 Nest 개발 서버를 현재 env 기준 포트로 실행한다.
echo "[Nest] port=${PORT} frontend=${FRONTEND_ORIGIN}"
(
  cd "${PROJECT_ROOT}/_NestJs"
  npm run start:dev
) > >(tee -a "${NEST_LOG_FILE}") 2> >(tee -a "${NEST_LOG_FILE}" >&2) &
NEST_PID=$!

# 프론트는 Nuxt 개발 서버를 현재 env 기준 포트로 실행한다.
echo "[Nuxt] port=${NUXT_PORT} backend=${BACKEND_ORIGIN}"
(
  cd "${PROJECT_ROOT}/_NuxtJs"
  npm run dev:app
) > >(tee -a "${NUXT_LOG_FILE}") 2> >(tee -a "${NUXT_LOG_FILE}" >&2) &
NUXT_PID=$!

# 둘 중 하나가 종료되면 wait 가 풀리고, trap 이 남은 프로세스를 함께 정리한다.
wait "${NEST_PID}" "${NUXT_PID}"
