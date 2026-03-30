#!/bin/bash

# 기준 디렉토리 설정 (스크립트가 위치한 곳을 기준으로 설정)
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${SOURCE_DIR}_tunnel"

echo "Edu_Hub 디렉토리의 내용을 ${TARGET_DIR} 로 복사합니다..."

# 1. rsync로 복사 (git 관련 파일 및 스크립트 자신 제외)
rsync -av \
  --exclude='.git' \
  --exclude='.gitignore' \
  --exclude='deploy_tunnel.sh' \
  "$SOURCE_DIR/" "$TARGET_DIR/"

# 2. primary.env 파일에서 포트 변경
ENV_FILE="$TARGET_DIR/config/runtime/primary.env"

if [ -f "$ENV_FILE" ]; then
    echo "primary.env 파일의 포트를 변경합니다 (3000 -> 3001, 4000 -> 4001)..."
    # macOS의 기본 sed에서 원본을 바로 수정하기 위해 -i '' 옵션을 사용합니다.
    sed -i '' 's/FRONTEND_PORT=3000/FRONTEND_PORT=3001/g' "$ENV_FILE"
    sed -i '' 's/BACKEND_PORT=4000/BACKEND_PORT=4001/g' "$ENV_FILE"
    
    # 만약 변수명이 위와 다를 경우를 대비한 보험용 치환 (단순 숫자 치환)
    # 단, 위에서 치환이 되지 않았고, 3000/4000 숫자만 있을 경우
    sed -i '' 's/=3000/=3001/g' "$ENV_FILE"
    sed -i '' 's/=4000/=4001/g' "$ENV_FILE"

    echo "포트 변경 완료."
else
    echo "경고: $ENV_FILE 파일을 찾을 수 없습니다."
fi

echo "배포 터널 동기화 작업이 완료되었습니다!"
