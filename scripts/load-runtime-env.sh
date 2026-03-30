#!/bin/bash

# 런타임 환경파일을 현재 셸에 불러오고, 로컬 개발 스크립트에서 공통으로
# 사용하는 프론트엔드/백엔드 관련 표준 환경변수를 계산해 export 한다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# 기본값은 공용 기준 환경파일이다. 필요하면 인자로 다른 env 파일을 넘길 수 있다.
ENV_FILE_INPUT="${1:-config/runtime/primary.env}"

# 상대경로와 절대경로 둘 다 받을 수 있게 env 파일 절대경로를 계산한다.
if [[ "${ENV_FILE_INPUT}" = /* ]]; then
  ENV_FILE_PATH="${ENV_FILE_INPUT}"
else
  ENV_FILE_PATH="${PROJECT_ROOT}/${ENV_FILE_INPUT}"
fi

# 잘못된 경로를 바로 찾을 수 있도록, env 파일이 없으면 즉시 중단한다.
if [[ ! -f "${ENV_FILE_PATH}" ]]; then
  echo "환경파일을 찾을 수 없습니다: ${ENV_FILE_PATH}" >&2
  return 1 2>/dev/null || exit 1
fi

# env 파일 안의 값을 현재 셸 환경으로 그대로 export 한다.
set -a
# shellcheck disable=SC1090
source "${ENV_FILE_PATH}"
set +a

# 포트 계산의 기준이 되는 두 값은 반드시 env 파일에 있어야 한다.
: "${FRONTEND_PORT:?FRONTEND_PORT 가 필요합니다.}"
: "${BACKEND_PORT:?BACKEND_PORT 가 필요합니다.}"

export PROJECT_ROOT
export ENV_FILE="${ENV_FILE_PATH}"
# 세부 변수는 env 파일에 직접 적어도 되고, 없으면 기본 규칙으로 자동 계산한다.
export NUXT_PORT="${NUXT_PORT:-${FRONTEND_PORT}}"
export PORT="${PORT:-${BACKEND_PORT}}"
export API_BASE="${API_BASE:-/api}"
export FRONTEND_ORIGIN="${FRONTEND_ORIGIN:-http://127.0.0.1:${FRONTEND_PORT}}"
export BACKEND_ORIGIN="${BACKEND_ORIGIN:-http://127.0.0.1:${BACKEND_PORT}}"
