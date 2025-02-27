#!/bin/zsh

# List available disk partitions with additional details (name, size, type)
selected_disk=$(
	diskutil list | awk '
  BEGIN { print "Device | Name | Size | Type" }
  /^\/dev\/disk[0-9]+/ {
    device = $1
    getline; getline
    name = $0
    sub(/^.*\(|\).*$/, "", name)
    getline; getline
    size = $0
    sub(/^.*:\s*/, "", size)
    getline; getline
    type = $0
    sub(/^.*:\s*/, "", type)
    print device " | " name " | " size " | " type
  }' | column -t -s '|' | fzf --prompt="Select a device: " | awk '{print $1}'
)

if [[ -z "$selected_disk" ]]; then
	echo "No device selected. Aborting."
	exit 1
fi

# Get the selected disk's size in GB
disk_size_bytes=$(diskutil info "$selected_disk" | awk '/Disk Size:/ {print $3}')
disk_size_gb=$((disk_size_bytes / 1024 / 1024 / 1024))

echo "Selected device: $selected_disk"
echo "Size: ${disk_size_gb}GB"

# Auto-recommend format based on disk size
if [[ $disk_size_gb -lt 32 ]]; then
	recommended_format="MS-DOS (FAT32)"
else
	recommended_format="ExFAT"
fi

# List formatting options with the recommended one pre-selected
format_types=("MS-DOS (FAT32)" "ExFAT")
selected_format=$(printf "%s\n" "${format_types[@]}" | fzf --prompt="Select a format type (Recommended: $recommended_format): ")

if [[ -z "$selected_format" ]]; then
	echo "No format type selected. Aborting."
	exit 1
fi

# Prompt for confirmation
echo "WARNING: Formatting will erase all data on $selected_disk!"
read "confirm?Are you sure you want to format $selected_disk as $selected_format? [y/N] "

if [[ "$confirm" != "y" ]]; then
	echo "Aborting..."
	exit 0
fi

# Format the disk
diskutil eraseDisk "$selected_format" "MySDCard" "$selected_disk"
echo "SD card formatted as $selected_format on $selected_disk."
