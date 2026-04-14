#!/bin/bash

# 공통 런타임 환경파일을 기준으로 로컬 Nest/Nuxt 개발 서버를 함께 실행하고,
# 각 프로세스 로그를 프로젝트 로그 디렉터리에 기록한다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
NEST_LOG_FILE="${PROJECT_ROOT}/logs/nest-dev.log"
NUXT_DIR="${PROJECT_ROOT}/_Client"
LOG_DIR="${NUXT_DIR}/logs"
NUXT_LOG_FILE="${LOG_DIR}/nuxt-dev.log"
NUXT_TARGET_URL=""

# 기본값은 primary.env 이고, 필요하면 다른 env 파일 경로를 첫 번째 인자로 넘길 수 있다.
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/load-runtime-env.sh" "${1:-config/runtime/primary.env}"
NUXT_TARGET_URL="http://localhost:${NUXT_PORT}"

mkdir -p "${PROJECT_ROOT}/logs" "${LOG_DIR}"
: > "${NEST_LOG_FILE}"
: > "${NUXT_LOG_FILE}"

assert_port_available() {
  local port="$1"
  local label="$2"

  if lsof -iTCP:"${port}" -sTCP:LISTEN -n -P >/dev/null 2>&1; then
    echo "${label} 포트 ${port} 가 이미 사용 중입니다. 기존 프로세스를 종료하거나 primary.env 포트를 변경해 주세요." >&2
    lsof -iTCP:"${port}" -sTCP:LISTEN -n -P >&2 || true
    exit 1
  fi
}

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

# 시작 전에 포트 충돌을 먼저 확인해서, Nest/Nuxt가 애매하게 실패하지 않게 한다.
assert_port_available "${PORT}" "Nest"
assert_port_available "${NUXT_PORT}" "Nuxt"

# 백엔드는 Nest 개발 서버를 현재 env 기준 포트로 실행한다.
echo "[Nest] port=${PORT} frontend=${FRONTEND_ORIGIN}"
(
  cd "${PROJECT_ROOT}/_Server"
  PORT="${PORT}" \
  FRONTEND_ORIGIN="${FRONTEND_ORIGIN}" \
  BACKEND_ORIGIN="${BACKEND_ORIGIN}" \
  API_BASE="${API_BASE}" \
  ENV_FILE="${ENV_FILE}" \
  npm run start:dev
) > >(tee -a "${NEST_LOG_FILE}") 2> >(tee -a "${NEST_LOG_FILE}" >&2) &
NEST_PID=$!

# 프론트는 Nuxt 개발 서버를 현재 env 기준 포트로 실행한다.
echo "[Nuxt] port=${NUXT_PORT} backend=${BACKEND_ORIGIN}"
(
  cd "${PROJECT_ROOT}/_Client"
  NUXT_PORT="${NUXT_PORT}" \
  PORT="${NUXT_PORT}" \
  BACKEND_ORIGIN="${BACKEND_ORIGIN}" \
  API_BASE="${API_BASE}" \
  npm run dev -- --port "${NUXT_PORT}"
) > >(tee -a "${NUXT_LOG_FILE}") 2> >(tee -a "${NUXT_LOG_FILE}" >&2) &
NUXT_PID=$!

if command -v open >/dev/null 2>&1; then
  (
    sleep 5
    open "${NUXT_TARGET_URL}" >/dev/null 2>&1 || true
  ) &
  echo "5초 후 기본 브라우저에서 ${NUXT_TARGET_URL} 을 엽니다."
fi

# 둘 중 하나가 종료되면 wait 가 풀리고, trap 이 남은 프로세스를 함께 정리한다.
wait "${NEST_PID}" "${NUXT_PID}"
