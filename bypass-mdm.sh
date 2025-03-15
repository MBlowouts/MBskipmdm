#!/bin/bash

# Define color codes
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# Display header
echo -e "${CYAN}Bypass MDM Script by Assaf Dori (assafdori.com)${NC}\n"

# Functions
log_info() {
    echo -e "${GRN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YEL}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_command_success() {
    if [ $? -ne 0 ]; then
        log_error "$1 failed. Exiting."
    fi
}

get_available_uid() {
    local available_uid=$(dscl . list /Users UniqueID | awk '{print $2}' | sort -n | tail -1)
    echo $((available_uid + 1))
}

block_mdm_domains() {
    local hosts_file="$1/etc/hosts"
    log_info "Blocking MDM domains in $hosts_file"
    echo "0.0.0.0 deviceenrollment.apple.com" >>"$hosts_file"
    echo "0.0.0.0 mdmenrollment.apple.com" >>"$hosts_file"
    echo "0.0.0.0 iprofiles.apple.com" >>"$hosts_file"
    log_info "MDM domains successfully blocked."
}

create_temp_user() {
    local dscl_path="/Volumes/Data/private/var/db/dslocal/nodes/Default"
    local username=$1
    local realName=$2
    local passw=$3

    log_info "Creating temporary user '$username'"
    local new_uid=$(get_available_uid)

    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
    check_command_success "User creation"
    
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "$new_uid"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
    mkdir -p "/Volumes/Data/Users/$username"
    check_command_success "User home directory creation"

    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
    dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
    check_command_success "Setting user password"

    dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"
    check_command_success "Adding user to admin group"

    log_info "Temporary user '$username' created successfully."
}

remove_profiles() {
    log_info "Removing configuration profiles."
    local base_path="$1/var/db/ConfigurationProfiles/Settings"
    rm -rf "$base_path/.cloudConfigHasActivationRecord"
    rm -rf "$base_path/.cloudConfigRecordFound"
    touch "$base_path/.cloudConfigProfileInstalled"
    touch "$base_path/.cloudConfigRecordNotFound"
    log_info "Configuration profiles removed."
}

# Main Menu
PS3='Please enter your choice: '
options=(
    "Bypass MDM from Recovery"
    "Disable Notification (SIP)"
    "Disable Notification (Recovery)"
    "Check MDM Enrollment"
    "Reboot & Exit"
)

select opt in "${options[@]}"; do
    case $opt in
    "Bypass MDM from Recovery")
        log_info "Selected: Bypass MDM from Recovery"
        
        if [ -d "/Volumes/Macintosh HD - Data" ]; then
            diskutil rename "Macintosh HD - Data" "Data"
            check_command_success "Renaming volume"
        fi

        read -p "Enter Temporary Fullname (Default is 'Apple'): " realName
        realName="${realName:-Apple}"
        read -p "Enter Temporary Username (Default is 'Apple'): " username
        username="${username:-Apple}"
        read -p "Enter Temporary Password (Default is '1234'): " passw
        passw="${passw:-1234}"

        create_temp_user "$username" "$realName" "$passw"
        block_mdm_domains "/Volumes/Macintosh HD"
        remove_profiles "/Volumes/Macintosh HD"

        log_info "MDM bypass completed. Exit terminal and reboot your Mac."
        break
        ;;

    "Disable Notification (SIP)")
        log_info "Selected: Disable Notification (SIP)"
        sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        log_info "Notifications disabled (SIP)."
        break
        ;;

    "Disable Notification (Recovery)")
        log_info "Selected: Disable Notification (Recovery)"
        remove_profiles "/Volumes/Macintosh HD"
        break
        ;;

    "Check MDM Enrollment")
        log_info "Selected: Check MDM Enrollment"
        echo -e "\n${RED}Please Insert Your Password To Proceed${NC}"
        sudo profiles show -type enrollment
        break
        ;;

    "Reboot & Exit")
        log_info "Rebooting..."
        reboot
        break
        ;;

    *)
        log_warn "Invalid option. Please try again."
        ;;
    esac
done
