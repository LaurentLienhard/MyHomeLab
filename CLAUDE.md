# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyHomeLab is an infrastructure-as-code repository for managing a Proxmox-based home lab environment. It combines Ansible automation for configuration management with Terraform for infrastructure provisioning. The project focuses on automated provisioning of Windows Server templates on Proxmox VE hosts and post-installation configuration of Proxmox servers.

## Repository Structure

- **HomeLab/** - Active development area (currently transitioning)
  - `ansible/` - Ansible configurations (in development)
  - `terrafrom/` - Terraform configurations (note: directory name has typo)
- **save old stuff/ansible/** - Legacy Ansible implementation with working playbooks
  - `playbooks/` - Production-ready playbooks
  - `roles/` - Custom Ansible roles (e.g., windowstemplate)
  - `inventory/` - Environment-specific inventories (production, test)
  - `files/` - Static files for deployment
  - `vars/` - Variable files (some Ansible Vault encrypted)

## Development Environment

### DevContainer Setup

The project uses a DevContainer with Alpine Linux base:
- Configured in `.devcontainer/devcontainer.json`
- Post-create command: Installs dependencies and runs `make prepare`
- Required tools: bash, direnv, git, openssh, python3, ansible, make, genisoimage

### Environment Configuration

The Ansible environment uses direnv for automatic environment activation:
- Python virtual environment at `${PWD}/.direnv`
- Custom Ansible configuration via environment variables
- Collections path: `${DIRENV_TMP_DIR}/ansible_collections`
- Roles path: `${DIRENV_TMP_DIR}/ansible_roles:${PWD}/roles`

## Common Commands

### Initial Setup
```bash
cd ansible
direnv allow
eval "$(direnv export bash)"
make prepare
```

### Ansible Environment Preparation
The `make prepare` target:
1. Verifies `.direnv` virtual environment exists
2. Installs ansible-core via pip
3. Installs Python dependencies from `requirements.txt` (pywinrm, ansible-lint)
4. Installs Ansible Galaxy requirements from `requirements.yml`

### Running Playbooks
```bash
# Test connectivity to Linux hosts
ansible-playbook -i inventory/test/hosts.yml playbooks/ping.ansible.yml

# Test connectivity to Windows hosts
ansible-playbook -i inventory/test/hosts.yml playbooks/ping.ansible.windows.yml

# Post-install Proxmox configuration
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml

# Provision Windows template
ansible-playbook -i inventory/test/hosts.yml playbooks/provision-template.ansible.yml
```

### Linting
```bash
ansible-lint playbooks/*.yml
```

## Architecture Details

### Proxmox Post-Installation (pve_post_install.ansible.yml)

This playbook configures Proxmox VE hosts after installation:
- Patches Proxmox Perl modules for Windows Cloudbase-Init compatibility
- Configures APT sources (removes enterprise repo, adds no-subscription repo)
- Disables the subscription nag dialog
- Configures NFS storage for ISOs, backups, and templates
- Sets up automated backup jobs with email notifications

### Windows Template Provisioning (provision-template.ansible.yml)

Automated creation of Windows Server templates on Proxmox:
1. Generates next available VMID (semi-random, idempotent based on hostname+template_name)
2. Creates unattended installation ISO with:
   - Autounattend.xml answer file
   - VirtIO drivers for network and storage
   - Cloudbase-Init installer
   - Provisioning scripts
3. Creates and starts VM with Windows ISO + provisioning ISO
4. Waits for automated Windows installation and sysprep (up to 120 minutes)
5. Removes CD drives and converts VM to template
6. Cleans up temporary files

Key variables (in `vars/wintpl.yml`):
- `template_name`: Template identifier
- `deploy_image`: Windows Server edition (2019/2022 variants)
- `os_iso_location`: Path to Windows installation ISO on Proxmox
- `vm_*`: VM resource specifications (cores, memory, disk)

### Inventory Organization

Inventories use hierarchical YAML structure:
- `hosts.yml`: Defines host groups (pve, dsclab)
- `group_vars/`: Variables applying to entire groups
- `host_vars/`: Host-specific variables (many encrypted with Ansible Vault)

Common host groups:
- `pve`: Proxmox VE hypervisor hosts
- `dsclab`: Windows lab servers (DC, file server, DSC server)

### Custom Roles

**windowstemplate**: Role for Windows template creation (split into numbered task files):
- `01-define-vmid.ansible.yml`: VMID allocation
- `02-download-iso.ansible.yml`: ISO preparation
- `03-prepare-files.ansible.yml`: Answer file templating
- `04-create-vm.ansible.yml`: VM creation and provisioning
- `05-cleanup.ansible.yml`: Post-provisioning cleanup

## Ansible Collections Used

- `community.general`: General-purpose modules
- `ansible.posix`: POSIX-specific modules
- `ansible.windows`: Core Windows modules
- `community.windows`: Extended Windows modules
- `microsoft.ad`: Active Directory management
- `laurentlienhard.managedwindowsserver`: Custom collection

## Ansible Configuration

Key settings in `ansible.cfg`:
- `interpreter_python=auto_silent`: Auto-detect Python interpreter
- `host_key_checking=False`: Disable SSH host key verification (lab environment)

Environment variables (set via `.envrc`):
- `ANSIBLE_STDOUT_CALLBACK=ansible.posix.debug`: Enhanced output
- `ANSIBLE_FORKS=10`: Parallel execution limit
- `ANSIBLE_CALLBACKS_ENABLED=timer,profile_tasks`: Performance profiling

## Working with Encrypted Files

Group and host variables are encrypted with Ansible Vault. To edit:
```bash
ansible-vault edit inventory/test/group_vars/pve.yml
```

## Important Notes

- The repository is transitioning from `save old stuff/ansible/` to `HomeLab/ansible/`
- When working with Windows provisioning, ensure VirtIO drivers and Cloudbase-Init MSI are current
- Windows template provisioning requires genisoimage for ISO creation
- Proxmox API credentials and NAS connection details are stored in encrypted vault files
- The devcontainer post-create command expects the working directory to be `/workspaces/MyHomeLab/ansible`
