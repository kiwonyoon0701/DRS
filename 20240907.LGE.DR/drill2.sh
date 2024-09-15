#!/bin/bash

# 1. 환경 변수 설정
export REGION="us-east-1"  # 사용할 AWS 리전

# 2. DRS에서 Source Server의 List 확인
echo "DRS에서 소스 서버 목록을 가져오는 중..."
SOURCE_SERVERS=$(aws drs describe-source-servers --region $REGION --query "items[].{SourceServerID:sourceServerID, Hostname:sourceProperties.identificationHints.hostname, InstanceID:sourceProperties.identificationHints.instanceId}" |jq)

if [ -z "$SOURCE_SERVERS" ]; then
  echo "소스 서버를 찾을 수 없습니다!"
  exit 1
fi

echo "소스 서버 목록:"
echo "$SOURCE_SERVERS"

# 3. Source Server ID 입력 받기
read -p "복구할 소스 서버의 Source Server ID를 입력하세요: " SERVER_ID

# 4. Initiate recovery 또는 Initiate recovery Drill 선택
echo "복구 유형을 선택하세요:"
echo "1) Initiate Recovery"
echo "2) Initiate Recovery Drill"
read -p "선택 (1 또는 2): " RECOVERY_TYPE

# 선택에 따라 AWS CLI 명령 실행
case $RECOVERY_TYPE in
  1)
    echo "Initiating Recovery for server $SERVER_ID..."
    aws drs start-recovery --source-servers "sourceServerID=$SERVER_ID" --region $REGION --no-is-drill
    ;;
  2)
    echo "Initiating Recovery Drill for server $SERVER_ID..."
    aws drs start-recovery --source-servers "sourceServerID=$SERVER_ID" --region $REGION --is-drill
    ;;
  *)
    echo "잘못된 선택입니다. 스크립트를 종료합니다."
    exit 1
    ;;
esac


echo "작업이 완료되었습니다."
