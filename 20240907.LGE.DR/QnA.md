# LGE DRS를 이용한 DR 문의

## Multi Region DR 구성 요건

### SAP 유관 시스템 DR 50EA



## 1. Failover 시 CPU Core Factor 변경 방법

현재는 방법이 없어 보임

---



## 2. Launch시 DR Site용 /etc/fstab 수정 방법(EFS 등)



### 1. EFS 생성 및 Source EC2에 Mount 

```
#!/bin/bash

# 변수 설정
VPC_ID="vpc-037583408fac9602d"
EFS_NAME="efs-us-east-1-web2"
REGION="us-west-2" # 미국 서부(오레곤) 리전

# 보안 그룹 ID 가져오기
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=web-source-security-group" --query "SecurityGroups[0].GroupId" --output text --region $REGION)

if [ -z "$SECURITY_GROUP_ID" ]; then
  echo "보안 그룹 ID를 찾을 수 없습니다!"
  exit 1
fi

echo "Security Group ID: $SECURITY_GROUP_ID"

# 1. Private Subnet ID 가져오기
PRIVATE_SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:aws:cloudformation:logical-id,Values=PrivateSubnet*" --query "Subnets[].SubnetId" --output text --region $REGION)

if [ -z "$PRIVATE_SUBNET_IDS" ]; then
  echo "Private Subnet을 찾을 수 없습니다!"
  exit 1
fi

echo "Private Subnet IDs: $PRIVATE_SUBNET_IDS"

# 2. EFS 생성
EFS_ID=$(aws efs create-file-system --creation-token $EFS_NAME --tags Key=Name,Value=$EFS_NAME --query "FileSystemId" --output text --region $REGION)

echo "EFS ID: $EFS_ID"

# 3. EFS가 available 상태가 될 때까지 대기
echo "EFS가 available 상태가 될 때까지 대기 중..."
while true; do
  EFS_STATE=$(aws efs describe-file-systems --file-system-id $EFS_ID --query "FileSystems[0].LifeCycleState" --output text --region $REGION)
  if [ "$EFS_STATE" == "available" ]; then
    echo "EFS가 available 상태가 되었습니다."
    break
  fi
  echo "현재 상태: $EFS_STATE. 10초 후 다시 확인합니다."
  sleep 10
done

# 4. 각 Private Subnet에 대해 Mount Target 생성
for SUBNET_ID in $PRIVATE_SUBNET_IDS; do
  echo "Subnet $SUBNET_ID에 Mount Target 생성 중..."
  aws efs create-mount-target --file-system-id $EFS_ID --subnet-id $SUBNET_ID --security-groups $SECURITY_GROUP_ID --region $REGION
done

echo "EFS 생성 및 Mount Target 설정 완료."

# 5. Security Group 수정 (필요한 경우)
# EFS에 접근할 수 있도록 NFS 트래픽을 허용해야 합니다.
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 2049 --source-group $SECURITY_GROUP_ID --region $REGION

echo "Security Group $SECURITY_GROUP_ID에 NFS 포트(2049) 접근 허용 완료."

# 6. EFS 마운트 명령어 출력
# 생성된 EFS를 마운트할 수 있는 명령어를 출력
echo "EFS를 마운트하려면 다음 명령어를 사용하세요:"
echo "sudo mount -t efs -o tls $EFS_ID:/ /mnt/efs"

# 마운트 포인트 디렉토리 생성 (필요한 경우)
echo "마운트 포인트 디렉토리가 없다면 다음 명령어로 생성하세요:"
echo "sudo mkdir -p /mnt/efs"
```



### 2. EC2에 EFS Util 설치

```
sudo yum install -y amazon-efs-utils
```



### 3. Mount Point 생성 및 Mount Test

```
sudo mkdir -p /mnt/efs3
sudo mount -t efs -o tls fs-0680af52cd2b8bda6:/ /mnt/efs3
df -h /mnt/efs3
Filesystem      Size  Used Avail Use% Mounted on
127.0.0.1:/     8.0E     0  8.0E   0% /mnt/efs3
```



### 4. /etc/fstab 수정 및 Test

```
sh-4.2$ sudo vi /etc/fstab
sh-4.2$ cat /etc/fstab
#
UUID=9f262948-b373-4d6f-b453-2a05174e900c     /           xfs    defaults,noatime  1   1
fs-0680af52cd2b8bda6:/ /mnt/efs3 efs _netdev,tls 0 0

sh-4.2$ sudo umount /mnt/efs3
sh-4.2$ df -h /mnt/efs3
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p1  8.0G  2.2G  5.8G  28% /

sh-4.2$ sudo mount /mnt/efs3
sh-4.2$ df -h /mnt/efs3
Filesystem      Size  Used Avail Use% Mounted on
127.0.0.1:/     8.0E     0  8.0E   0% /mnt/efs3
```





---





### 3. IP나 Configuration 수정을 위한 방법



### 4. Workload별 Template 다중 구성 방법



### 5. 특정 Disk Volume 제외 방법



### 6. Route 53을 통한 Failover BP



### 7. IAC Level BP





::::expand{header="화면 보기" defaultExpanded=false}

![create cf template](images/1.png)

::::



