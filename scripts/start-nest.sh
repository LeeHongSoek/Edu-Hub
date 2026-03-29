#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/load-runtime-env.sh" "${1:-config/runtime/primary.env}"

cd "${PROJECT_ROOT}/_NestJs"
echo "[Nest] port=${PORT} frontend=${FRONTEND_ORIGIN}"
npm run "${2:-start:dev}"
