# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible-based homelab automation repository focused on managing Proxmox VE (PVE) infrastructure and provisioning Windows Server VM templates. The repository automates Proxmox configuration, Windows template creation, and manages both production and test environments.

## Repository Structure

```
ansible/
├── playbooks/          # Main automation playbooks
├── roles/              # Reusable Ansible roles
│   └── windowstemplate/  # Windows VM template provisioning role
├── inventory/          # Environment inventories (production, test)
│   ├── production/
│   └── test/
├── vars/               # Variable files for playbooks
├── files/              # Static files and templates
│   └── proxmox/        # Proxmox configuration files
└── ansible.cfg         # Ansible configuration
```

## Key Commands

### Running Playbooks

All playbooks should be run from the `ansible/` directory:

```bash
# Test connectivity to Proxmox hosts
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml

# Test connectivity to Windows hosts
ansible-playbook -i inventory/test/hosts.yml playbooks/ping.ansible.windows.yml

# Configure Proxmox VE post-installation
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml

# Provision Windows Server template
ansible-playbook -i inventory/test/hosts.yml playbooks/provision-template.ansible.yml

# Run with specific tags (e.g., update only)
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --tags update

# Use windowstemplate role
ansible-playbook -i inventory/test/hosts.yml playbooks/testrole.ansible.yml
```

### Installing Dependencies

```bash
# Install required Ansible collections and roles
ansible-galaxy install -r ansible/requirements.yml

# Update collections
ansible-galaxy collection install -r ansible/requirements.yml --force
```

### Working with Ansible Vault

The repository uses Ansible Vault for sensitive data (e.g., `inventory/production/group_vars/pve.yml`):

```bash
# View encrypted file
ansible-vault view ansible/inventory/production/group_vars/pve.yml

# Edit encrypted file
ansible-vault edit ansible/inventory/production/group_vars/pve.yml

# Encrypt a new file
ansible-vault encrypt ansible/inventory/production/group_vars/newfile.yml
```

## Architecture

### Inventory Organization

The repository uses a dual-inventory structure:

- **production/**: Contains the production Proxmox host (`pve1`)
- **test/**: Contains both Proxmox host and test Windows servers (dsclab group: srvdc01, srvfile01, srvdsc01)

Host variables and group variables are encrypted with Ansible Vault for security.

### Proxmox Post-Installation (`pve_post_install.ansible.yml`)

This playbook configures a fresh Proxmox VE installation:

1. **Patches Proxmox for Windows CloudInit compatibility** by copying modified Perl modules (`Cloudinit.pm`, `Qemu.pm`)
2. **Fixes repository sources** to use no-subscription repos instead of enterprise
3. **Disables subscription nag** in the web UI
4. **Configures NFS storage** for ISO images, backups, and templates
5. **Sets up automated backups** via vzdump with email notifications

Key variables (in encrypted group_vars):
- `nas_ip`: NFS server IP address
- `mailto`: Email for backup notifications

### Windows Template Provisioning

Two approaches exist for creating Windows Server templates:

#### 1. Direct Playbook (`provision-template.ansible.yml`)

Legacy approach that:
- Generates semi-random, idempotent VMID using hostname and template name as seed
- Creates temporary directory for ISO preparation
- Templates `autounattend.xml` answer file from variables
- Builds custom provisioning ISO with drivers, scripts, and answer file using `genisoimage`
- Creates VM with two CD drives (OS ISO + provisioning ISO)
- Waits for automated installation and sysprep (up to 120 minutes)
- Converts VM to template and cleans up

#### 2. Role-Based Approach (`windowstemplate` role)

Modular role with separate task files:
- `01-define-vmid.ansible.yml`: Determines next available VMID
- `02-download-iso.ansible.yml`: Downloads required ISOs
- `03-prepare-files.ansible.yml`: Prepares provisioning files
- `04-create-vm.ansible.yml`: Creates VM with CloudInit support
- `05-cleanup.ansible.yml`: Removes temporary files

Key difference: The role approach includes CloudInit drive (`--ide2 local:cloudinit`) for cloud-init based provisioning.

### Template Variables (`vars/wintpl.yml`)

Critical configuration for Windows templates:

- `template_name`: Template identifier (e.g., "2022-tpl")
- `os_iso_location`: Path to Windows Server ISO (format: `storage:iso/filename.iso`)
- `deploy_image`: Exact Windows edition string (e.g., "Windows Server 2022 SERVERDATACENTER")
- `vm_*`: VM resource specifications (cores, sockets, memory)
- `pve_storage_id`: Proxmox storage target (e.g., "local-lvm")
- `format`: Disk format - use "raw" for LVM, "qcow2" for file-based storage
- `agent`: QEMU guest agent configuration string

Valid `deploy_image` options are documented inline for Server 2019 and 2022 editions.

## Important Notes

### Proxmox-Specific Considerations

- The repository patches Proxmox Perl modules (`/usr/share/perl5/PVE/`) to enable Windows CloudInit compatibility
- Always restart `pvedaemon.service` after modifying Proxmox configuration files
- VM creation uses `qm` (QEMU Manager) commands directly rather than Ansible modules
- VMID generation uses seeded random to ensure idempotency across runs

### Windows Template Provisioning

- Template creation is a long-running process (up to 2 hours) due to Windows updates and sysprep
- The `qm wait` command monitors VM shutdown to detect completion
- ISO files are stored in NFS share (`nas-iso`) or local Proxmox storage
- VirtIO drivers must be available in the provisioning ISO for optimal performance
- The `autounattend.xml` answer file automates the entire Windows installation

### Ansible Configuration

- `interpreter_python=auto_silent`: Automatically detects Python interpreter
- `host_key_checking=False`: Disabled for homelab convenience (re-enable for production)

## Required Collections

From `requirements.yml`:
- `community.general`: General community modules
- `ansible.posix`: POSIX-specific modules
- `ansible.windows`: Core Windows modules
- `community.windows`: Extended Windows functionality
- `laurentlienhard.managedwindowsserver`: Custom Windows Server management
- `microsoft.ad`: Active Directory management
- `geerlingguy.java`: Java installation role

## Testing and Validation

Use ping playbooks to verify connectivity:
- `ping.ansible.yml`: Tests Proxmox hosts via SSH
- `ping.ansible.windows.yml`: Tests Windows hosts via WinRM

Test with the `test.ansible.yml` playbook for experimentation before running against production.
