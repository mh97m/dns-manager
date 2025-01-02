#!/bin/bash

# Colors for output
RESET_COLOR="\033[0m"
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
ORANGE="\033[1;33m"
BOLD="\033[1m"
BREACKER="#####################################"

# File containing DNS addresses (one address per line)
DNS_FILE="dns_addresses.txt"

# Check if the DNS file exists
if [[ ! -f "$DNS_FILE" ]]; then
  echo -e "${RED}Error: DNS file '$DNS_FILE' not found in the script's directory.${RESET_COLOR}"
  exit 1
fi

DISABLE_IPV6=false

# Parse arguments
if [[ $# -ge 1 ]]; then
  case "$1" in
    set|reset)
      ACTION="$1"
      ;;
    *)
      echo -e "${RED}Invalid argument: $1${RESET_COLOR}"
      echo -e "${RED}Usage: $0 [set|reset] [--disable-ipv6]${RESET_COLOR}"
      exit 1
      ;;
  esac
else
  echo -e "${RED}Usage: $0 [set|reset] [--disable-ipv6]${RESET_COLOR}"
  exit 1
fi

if [[ "$2" == "--disable-ipv6" ]]; then
  DISABLE_IPV6=true
fi

# Function to handle DNS configuration
configure_network() {
  local connection="$1"
  local action="$2"
  local dns_addresses="$3"

  echo -e "\n${BREACKER}"
  echo -e "Processing connection: ${BLUE}${BOLD}$connection${RESET_COLOR}"
  echo "${BREACKER}"

  if [[ "$action" == "set" ]]; then
    # Set DNS addresses
    if nmcli con mod "$connection" ipv4.dns "$dns_addresses"; then
      echo -e "${PURPLE}DNS set to $dns_addresses for ${BLUE}${BOLD}$connection${RESET_COLOR}"
    else
      echo -e "${RED}Failed to set DNS for ${BLUE}${BOLD}$connection${RESET_COLOR}"
      echo "Reason: $(nmcli con show "$connection" 2>&1)"
    fi

    # Disable auto-DNS
    if nmcli con mod "$connection" ipv4.ignore-auto-dns yes; then
      echo -e "${GREEN}Auto-DNS disabled for ${BLUE}${BOLD}$connection${RESET_COLOR}"
    else
      echo -e "${RED}Failed to disable auto-DNS for ${BLUE}${BOLD}$connection${RESET_COLOR}"
      echo "Reason: $(nmcli con show "$connection" 2>&1)"
    fi
  elif [[ "$action" == "reset" ]]; then
    # Reset DNS addresses
    if nmcli con mod "$connection" ipv4.dns ""; then
      echo -e "${PURPLE}DNS reset for ${BLUE}${BOLD}$connection${RESET_COLOR}"
    else
      echo -e "${RED}Failed to reset DNS for ${BLUE}${BOLD}$connection${RESET_COLOR}"
      echo "Reason: $(nmcli con show "$connection" 2>&1)"
    fi

    # Enable auto-DNS
    if nmcli con mod "$connection" ipv4.ignore-auto-dns no; then
      echo -e "${GREEN}Auto-DNS enabled for ${BLUE}${BOLD}$connection${RESET_COLOR}"
    else
      echo -e "${RED}Failed to enable auto-DNS for ${BLUE}${BOLD}$connection${RESET_COLOR}"
      echo "Reason: $(nmcli con show "$connection" 2>&1)"
    fi
  fi

  # Disable IPv6 if requested
  if $DISABLE_IPV6; then
    if nmcli con mod "$connection" ipv6.method "ignore"; then
      echo -e "${PURPLE}IPv6 disabled for ${BLUE}${BOLD}$connection${RESET_COLOR}"
    else
      echo -e "${RED}Failed to disable IPv6 for ${BLUE}${BOLD}$connection${RESET_COLOR}"
      echo "Reason: $(nmcli con show "$connection" 2>&1)"
    fi
  fi

  # Bring up the connection
  if nmcli con up "$connection"; then
    echo -e "${GREEN}Connection ${BLUE}${BOLD}$connection${RESET_COLOR} successfully activated.${RESET_COLOR}"
  else
    echo -e "${RED}Failed to bring up ${BLUE}${BOLD}$connection${RESET_COLOR}"
    echo "Reason: $(nmcli con up "$connection" 2>&1)"
  fi

  echo -e "${BREACKER}\n"
}

# Main function to handle DNS settings
handle_dns() {
  # Read DNS addresses from file
  local dns_addresses=$(paste -sd ',' "$DNS_FILE" | sed 's/^,//')

  if [[ -z "$dns_addresses" && "$ACTION" == "set" ]]; then
    echo -e "${RED}Error: No DNS addresses found in $DNS_FILE.${RESET_COLOR}"
    exit 1
  fi

  if [[ "$ACTION" == "set" ]]; then
    echo "Setting DNS to: $dns_addresses"
  else
    echo "Resetting DNS for all non-VPN connections."
  fi

  # Loop through all non-VPN network connections
  while IFS= read -r connection; do
    CLEAN_CONNECTION=$(echo "$connection" | cut -d ':' -f 1)
    configure_network "$CLEAN_CONNECTION" "$ACTION" "$dns_addresses"
  done < <(nmcli -t -f NAME,TYPE con show | grep -Ev ":vpn|:loopback")

  if [[ "$ACTION" == "set" ]]; then
    echo -e "${GREEN}DNS addresses set successfully for all non-VPN connections.${RESET_COLOR}"
  else
    echo -e "${GREEN}DNS reset successfully for all non-VPN connections.${RESET_COLOR}"
  fi
}

# Execute the script
handle_dns
