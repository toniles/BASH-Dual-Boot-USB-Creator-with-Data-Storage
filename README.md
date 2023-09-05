# BASH-Dual-Boot-USB-Creator-with-Data-Storage
This script assists in preparing two USB drives, one for Windows and another for Fedora, both with a dedicated data partition. It ensures the USBs are bootable and that specific data is copied to their respective data partitions.

## Features:
- **Superuser Check**: Verifies that the script is being run with superuser privileges.
- **Logging**: All actions and possible errors are logged in a file named `log.txt`.
- **Partitioning and Formatting**: Automatically partitions and formats the USB drives to accommodate the OS and data.
- **Data Copy**: Copies specific files (e.g., Logopedia.zip) to the data partition.
- **Bootable USB Creation**: Uses provided ISO files to make the USBs bootable with Windows and Fedora.

## Prerequisites:
- Bash environment.
- Required tools: `mountpoint`, `wipefs`, `sfdisk`, `mkfs.fat`, `mkfs.exfat`, `rsync`, `woeusb`, and `dd`.

## Usage:
1. Adjust paths for Windows and Fedora ISOs, and other files as needed in the script.
2. Run the script with superuser privileges: `sudo bash pen_modified.sh`

## Note:
Ensure you adjust the USB device paths (`/dev/sdc` and `/dev/sdd` by default) to match your system's configuration. Running the script on incorrect devices may result in data loss.


![imagen](https://github.com/toniles/BASH-Dual-Boot-USB-Creator-with-Data-Storage/assets/120176462/b52c4295-113f-4fe0-b50c-7b96902c6594)
