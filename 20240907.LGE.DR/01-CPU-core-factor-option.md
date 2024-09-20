

# 1. Failover시 DR Site CPU Core Options(Factor) 적용 방법



### 1. Source Server => Actions => Edit EC2 launch template 

![image-20240920140140989](images/image-20240920140140989.png)



---

### 2. Source Server에 Assign된 EC Launch Template 확인

![image-20240920140213746](images/image-20240920140213746.png)



---

### 3. Template에서 Advanced Option => Cpu options 수정 => Create Template Version

![image-20240920140310388](images/image-20240920140310388.png)



---

### 4. 새로운 Template Version으로 Default Version Update

![image-20240920140339920](images/image-20240920140339920.png)



![image-20240920140500924](images/image-20240920140500924.png)



![image-20240920140520012](images/image-20240920140520012.png)



---

### 5. Template에서 Threads per core 확인

![image-20240920140602907](images/image-20240920140602907.png)



---

### 6. Failover Drill Test 실행 

![image-20240920140650324](images/image-20240920140650324.png)



---

### 7. Failover 후 CPU Factor 확인

![image-20240920142133103](images/image-20240920142133103.png)



```
sh-4.2$ cat /proc/cpuinfo |grep 'core id'
core id         : 0
core id         : 1
core id         : 0
core id         : 1
```





















