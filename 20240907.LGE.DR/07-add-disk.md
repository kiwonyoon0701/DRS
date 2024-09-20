```



#!/bin/bash

# Define the devices and their mount points
declare -A disks
disks=(["/dev/nvme1n1"]="/data1" ["/dev/nvme2n1"]="/data2" ["/dev/nvme3n1"]="/data3")

# Install xfsprogs if not already installed
if ! command -v mkfs.xfs &> /dev/null; then
    echo "Installing xfsprogs..."
    sudo yum install -y xfsprogs
fi

# Create file systems, mount directories, and update /etc/fstab
for device in "${!disks[@]}"; do
    mount_point="${disks[$device]}"
    
    # Format the disk with XFS
    echo "Formatting $device as XFS..."
    sudo mkfs.xfs -f "$device"
    
    # Create the mount point directory if it doesn't exist
    if [ ! -d "$mount_point" ]; then
        echo "Creating mount point $mount_point..."
        sudo mkdir -p "$mount_point"
    fi
    
    # Mount the device
    echo "Mounting $device to $mount_point..."
    sudo mount "$device" "$mount_point"
    
    # Get UUID of the device
    uuid=$(sudo blkid -s UUID -o value "$device")
    
    # Add entry to /etc/fstab for persistence across reboots
    echo "Updating /etc/fstab..."
    echo "UUID=$uuid $mount_point xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab
done

echo "All disks have been formatted, mounted, and added to /etc/fstab."
```



```
#!/bin/bash

# Define the directories
directories=("/data1" "/data2" "/data3")

# Create files in each directory
for dir in "${directories[@]}"; do
    # Create directory if it doesn't exist
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
    
    # Generate 10 random files
    for i in {1..10}; do
        # Generate a random size between 1MB and 100MB
        size=$(( (RANDOM % 100 + 1) * 1024 * 1024 ))  # Size in bytes
        
        # Generate a random file name
        file_name="$dir/random_file_$RANDOM.bin"
        
        # Create the file with random data
        echo "Creating $file_name with size $size bytes"
        dd if=/dev/urandom of="$file_name" bs=1M count=$((size / (1024 * 1024))) iflag=fullblock
    done
done

echo "Random files created successfully."
```













































