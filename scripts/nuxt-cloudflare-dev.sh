#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
NUXT_DIR="${PROJECT_ROOT}/_NuxtJs"
INFO_FILE="${PROJECT_ROOT}/ex_url.info"
LOG_DIR="${NUXT_DIR}/logs"
NUXT_LOG_FILE="${LOG_DIR}/nuxt-dev.log"
CLOUDFLARED_LOG_FILE="${LOG_DIR}/cloudflared.log"
NUXT_PORT="${NUXT_PORT:-3000}"
NUXT_TARGET_URL="http://localhost:${NUXT_PORT}"

mkdir -p "${LOG_DIR}"
: > "${NUXT_LOG_FILE}"
: > "${CLOUDFLARED_LOG_FILE}"

if ! command -v npx >/dev/null 2>&1; then
  echo "npx 명령을 찾을 수 없습니다. Node.js/npm 설치 상태를 확인해 주세요." >&2
  exit 1
fi

cleanup() {
  if [[ -n "${CLOUDFLARED_PID:-}" ]] && kill -0 "${CLOUDFLARED_PID}" >/dev/null 2>&1; then
    kill "${CLOUDFLARED_PID}" >/dev/null 2>&1 || true
  fi

  if [[ -n "${NUXT_PID:-}" ]] && kill -0 "${NUXT_PID}" >/dev/null 2>&1; then
    kill "${NUXT_PID}" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT INT TERM

echo "Nuxt 개발 서버를 시작합니다: ${NUXT_TARGET_URL}"
(
  cd "${NUXT_DIR}"
  npm run dev
) > >(tee -a "${NUXT_LOG_FILE}") 2> >(tee -a "${NUXT_LOG_FILE}" >&2) &
NUXT_PID=$!

echo "Nuxt 응답 대기 중..."
for _ in $(seq 1 120); do
  if curl --silent --fail "${NUXT_TARGET_URL}" >/dev/null 2>&1; then
    break
  fi

  if ! kill -0 "${NUXT_PID}" >/dev/null 2>&1; then
    echo "Nuxt 서버가 준비되기 전에 종료되었습니다. 로그: ${NUXT_LOG_FILE}" >&2
    exit 1
  fi

  sleep 1
done

if ! curl --silent --fail "${NUXT_TARGET_URL}" >/dev/null 2>&1; then
  echo "Nuxt 서버가 ${NUXT_TARGET_URL} 에서 준비되지 않았습니다. 로그: ${NUXT_LOG_FILE}" >&2
  exit 1
fi

echo "Cloudflare Tunnel을 시작합니다."
(
  cd "${PROJECT_ROOT}"
  npx cloudflared tunnel --url "${NUXT_TARGET_URL}"
) > >(tee -a "${CLOUDFLARED_LOG_FILE}") 2> >(tee -a "${CLOUDFLARED_LOG_FILE}" >&2) &
CLOUDFLARED_PID=$!

EXTERNAL_URL=""
for _ in $(seq 1 120); do
  if ! kill -0 "${CLOUDFLARED_PID}" >/dev/null 2>&1; then
    echo "Cloudflare Tunnel이 URL 생성 전에 종료되었습니다. 로그: ${CLOUDFLARED_LOG_FILE}" >&2
    exit 1
  fi

  if [[ -f "${CLOUDFLARED_LOG_FILE}" ]]; then
    EXTERNAL_URL="$(grep -Eo 'https://[-a-z0-9]+\.trycloudflare\.com' "${CLOUDFLARED_LOG_FILE}" | tail -n 1 || true)"
    if [[ -n "${EXTERNAL_URL}" ]]; then
      break
    fi
  fi

  sleep 1
done

if [[ -z "${EXTERNAL_URL}" ]]; then
  echo "Cloudflare 외부 URL을 찾지 못했습니다. 로그: ${CLOUDFLARED_LOG_FILE}" >&2
  exit 1
fi

if command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "${EXTERNAL_URL}" | pbcopy
  echo "클립보드에 외부 URL을 복사했습니다."
fi

if command -v open >/dev/null 2>&1; then
  open "${EXTERNAL_URL}" >/dev/null 2>&1 || true
  echo "기본 브라우저에서 외부 URL을 열었습니다."
fi

cat > "${INFO_FILE}" <<EOF
external_url=${EXTERNAL_URL}
local_url=${NUXT_TARGET_URL}
created_at=$(date '+%Y-%m-%d %H:%M:%S %Z')
cloudflared_log=${CLOUDFLARED_LOG_FILE}
nuxt_log=${NUXT_LOG_FILE}
EOF

echo "외부 URL 저장 완료: ${INFO_FILE}"
echo "Cloudflare URL: ${EXTERNAL_URL}"

echo ""
echo ""
echo "ex_url.info 내용:"
echo "--------------------------------------------------------------------"
cat "${INFO_FILE}"
echo "--------------------------------------------------------------------"
echo ""
echo ""

echo "종료하려면 Ctrl+C 를 누르세요."

wait "${NUXT_PID}"
