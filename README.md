# DNS Manager Script

This script manages DNS settings for non-VPN network connections on a Linux system using the `nmcli` tool. It supports setting and resetting DNS addresses and includes optional functionality to disable IPv6 on specified networks.

---

## Features

1. **Set or Reset DNS**:
   - Allows setting custom DNS addresses or resetting to default settings for all non-VPN network connections.

2. **Excludes VPN Connections**:
   - Ensures no DNS changes are applied to VPN connections.

3. **IPv6 Disabling (Optional)**:
   - Provides a flag to disable IPv6 for specified connections.

4. **Reads DNS from File**:
   - Reads DNS addresses from a `dns_addresses.txt` file in the script's directory.

5. **Color-Coded Output**:
   - Blue and bold for network names.
   - Orange for key messages like DNS settings.
   - Green for success messages.
   - Red for error messages.

---

## Requirements

- Linux system with `nmcli` installed.
- Sudo privileges to modify network configurations.
- A `dns_addresses.txt` file in the same directory as the script, containing DNS addresses (one per line).

---

## Usage

### Basic Syntax

```bash
sudo ./dns_manager.sh [set|reset] [--disable-ipv6]
```

### Arguments

1. **set**:
   - Sets the DNS addresses listed in `dns_addresses.txt` for all non-VPN connections.
   
2. **reset**:
   - Resets DNS addresses for all non-VPN connections and enables auto-DNS.

3. **--disable-ipv6** (Optional):
   - Disables IPv6 for all non-VPN connections.

### Example Usage

#### Set DNS with IPv6 Disabled
```bash
sudo ./dns_manager.sh set --disable-ipv6
```

#### Reset DNS (Without Modifying IPv6)
```bash
sudo ./dns_manager.sh reset
```

---

## File Requirements

### `dns_addresses.txt`
This file should be in the same directory as the script and contain DNS addresses, one per line. Example:

```
10.202.10.102
10.202.10.202
```

---

## Bash Alias

To simplify usage, add the following alias to your `~/.bashrc` file:

```bash
alias dns_manager='sudo /path/to/dns_manager.sh'
```

Reload the `.bashrc` file to apply the alias:

```bash
source ~/.bashrc
```

Now you can use the script with:

```bash
dns_manager set --disable-ipv6
dns_manager reset
```

---

## Notes

- The script ignores loopback and VPN connections by default.
- Ensure that `dns_addresses.txt` contains valid DNS addresses.
- Run the script with `sudo` to avoid permission issues.
- For best results, ensure the network connections are active and properly configured.

