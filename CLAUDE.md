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
│   ├── production/      # Production Proxmox host (pve1)
│   │   ├── hosts.yml
│   │   ├── group_vars/  # Encrypted group variables (vault)
│   │   └── host_vars/   # Host-specific variables
│   └── test/            # Test Proxmox host + Windows VMs (dsclab group)
│       ├── hosts.yml
│       ├── group_vars/  # Encrypted group variables (vault)
│       └── host_vars/   # Host-specific variables
├── vars/                # Shared variable files
│   └── wintpl.yml       # Windows template provisioning configuration
├── files/               # Static files for provisioning
│   ├── proxmox/         # Proxmox patches and configuration files
│   ├── windowstemplate/ # Windows drivers, scripts, and ISO prep files
│   └── ...
├── ansible.cfg          # Ansible configuration
├── requirements.txt     # Python pip dependencies
├── requirements.yml     # Ansible Galaxy collections/roles
└── Makefile             # Build automation for workspace setup
```

## Development Environment Setup

### Quick Start (Recommended)

Use the **Dev Container** for automatic setup:
```bash
# 1. Clone the repository
git clone <repo-url>
cd MyHomeLab

# 2. Open in VSCode and accept "Reopen in Container" prompt
# The devcontainer will automatically install all dependencies
```

The Dev Container includes:
- Alpine Linux base with all required system tools
- Python 3 with virtual environment
- direnv for environment variable management
- All Python and Ansible Galaxy dependencies

### Manual Setup (One-Time)

If you prefer not to use Dev Container, follow these steps:

```bash
# 1. Clone the repository
git clone <repo-url>
cd MyHomeLab/ansible

# 2. Install direnv if not already installed
# See https://direnv.net/docs/installation.html for your OS

# 3. Allow direnv to load .envrc
direnv allow

# 4. Install all dependencies (Ansible, collections, roles)
make prepare

# 5. Configure Ansible Vault password (optional but recommended)
# Create .env.local in the ansible/ directory with:
# ANSIBLE_VAULT_PASSWORD_FILE=.vault_password
# Then place your vault password in .vault_password file
```

**Note:** The `make prepare` command requires direnv to have already set up the Python virtual environment. If you see "Venv not found", ensure you've run `direnv allow` first.

### Environment Variables

The `.envrc` file automatically configures:
- **ANSIBLE_STDOUT_CALLBACK**: Enhanced debug output formatting
- **ANSIBLE_FORKS**: Parallel execution limit (10 concurrent tasks)
- **ANSIBLE_ROLES_PATH**: Custom roles directory
- **ANSIBLE_COLLECTIONS_PATH**: Custom collections directory
- **ANSIBLE_CALLBACKS_ENABLED**: Performance profiling (timer, profile_tasks)

### Python Dependencies

Managed by `requirements.txt`:
- **ansible-core==2.17.7**: Core Ansible framework
- **pywinrm>=0.2.2**: Windows Remote Management protocol for WinRM connectivity
- **ansible-lint**: Playbook syntax checking and linting

### Ansible Galaxy Dependencies

Collections and roles installed via `requirements.yml`:
- `community.general`: General-purpose Ansible modules
- `ansible.posix`: POSIX/Linux-specific modules
- `ansible.windows`: Core Windows management modules
- `community.windows`: Extended Windows community modules
- `laurentlienhard.managedwindowsserver`: Custom Windows Server management
- `microsoft.ad`: Active Directory domain management
- `geerlingguy.java`: Java installation role

## Running Playbooks

### Quick Reference

All playbooks should be run from the `ansible/` directory:

```bash
# Test connectivity (Proxmox SSH)
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml

# Test connectivity (Windows WinRM)
ansible-playbook -i inventory/test/hosts.yml playbooks/ping.ansible.windows.yml

# Initial Proxmox setup (run once on fresh Proxmox installation)
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml

# Provision Windows Server template (role-based, recommended)
ansible-playbook -i inventory/test/hosts.yml playbooks/testrole.ansible.yml

# Provision Windows Server template (legacy direct approach)
ansible-playbook -i inventory/test/hosts.yml playbooks/provision-template.ansible.yml

# Configure test environment (Active Directory, Windows settings)
ansible-playbook -i inventory/test/hosts.yml playbooks/test.ansible.yml
```

### Selective Execution

```bash
# Run only specific tags (e.g., update Proxmox packages only)
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --tags update

# Run against specific hosts or groups
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --limit pve1

# Dry-run mode (show what would happen without making changes)
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --check

# Dry-run with detailed output of what would change
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --check --diff
```

### Debugging and Verbosity

```bash
# Verbose output (show task details)
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml -v

# Very verbose (show all variable assignments and task details)
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml -vv

# Debug mode (show all variable values and task execution)
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml -vvv
```

### Linting and Testing

```bash
# Lint a single playbook for syntax and best practices
ansible-lint playbooks/pve_post_install.ansible.yml

# Lint all playbooks
ansible-lint playbooks/

# Lint with detailed output
ansible-lint -v playbooks/

# Test playbook syntax without running (does not validate variables)
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml --syntax-check
```

**Best Practice Workflow:**
1. Run `ansible-lint` on all changes before committing
2. Test with `--syntax-check` to catch variable issues early
3. Run with `--check` to preview changes on actual infrastructure
4. Review output with `-v` or `-vv` for detailed debugging

### Monitoring Playbook Execution

For long-running playbooks like Windows template provisioning, monitor progress on the target system:

```bash
# On Proxmox host during VM creation (check VM status)
qm list
qm status {vmid}

# Monitor VM console output (requires SSH access to Proxmox)
ssh root@proxmox-host 'qm terminal {vmid}'

# Check if VM is still running (waits for completion)
qm wait {vmid}

# View task timings (already captured in playbook output if callbacks enabled)
# Look for output like: "Longest running operations:"
```

**Note:** Enable `ANSIBLE_CALLBACKS_ENABLED=timer,profile_tasks` in `.envrc` (default) to see task timing in playbook output.

### Working with Ansible Vault

The repository uses Ansible Vault to encrypt sensitive data in inventory files:

```bash
# View encrypted file without editing
ansible-vault view inventory/production/group_vars/pve.yml

# Edit encrypted file (prompts for vault password)
ansible-vault edit inventory/production/group_vars/pve.yml

# Encrypt a new file
ansible-vault encrypt inventory/production/group_vars/newfile.yml

# Run playbook with vault password (interactive prompt)
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --ask-vault-pass

# Run playbook with vault password from file (recommended)
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --vault-password-file=.vault_password
```

**Vault Password Configuration:**

Option 1: Password file (Recommended for automated workflows)
```bash
# Create password file in ansible/ directory
echo "your-vault-password" > ansible/.vault_password
chmod 600 ansible/.vault_password  # Restrict permissions
# Add .vault_password to .gitignore (should already be there)

# Then run playbooks without prompting:
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml
```

Option 2: Environment variable (via `.env.local`)
```bash
# Create ansible/.env.local
echo "ANSIBLE_VAULT_PASSWORD_FILE=.vault_password" > ansible/.env.local

# The .envrc file automatically sources .env.local when you cd into ansible/
# Ensure your vault password file is in the same location
```

Option 3: Interactive prompt (least convenient)
```bash
# Run playbook with prompt for vault password
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml --ask-vault-pass
```

**Security Note:** Never commit `.vault_password` to git. Ensure it's in `.gitignore`.

## Playbook Reference

### Connectivity Tests

#### `ping.ansible.yml` - Proxmox Connectivity
Tests SSH connectivity to Proxmox hosts (pve group). Use this to verify infrastructure is reachable before running complex playbooks.
```bash
ansible-playbook -i inventory/production/hosts.yml playbooks/ping.ansible.yml
```

#### `ping.ansible.windows.yml` - Windows Connectivity
Tests WinRM connectivity to Windows hosts. Validates Windows-specific communication is working.
```bash
ansible-playbook -i inventory/test/hosts.yml playbooks/ping.ansible.windows.yml
```

### Proxmox Management

#### `pve_post_install.ansible.yml` - Fresh Proxmox Configuration
Run once on a fresh Proxmox VE installation to configure it for this repository's needs. This is a long-duration playbook (typically 20-30 minutes).

**What it does:**
1. Patches Proxmox Perl modules (`Cloudinit.pm`, `Qemu.pm`) to enable Windows CloudInit compatibility
2. Fixes APT repository sources (switches to no-subscription repos, removes enterprise)
3. Disables subscription nag screen in web UI
4. Installs necessary packages (Python, proxmoxer, vim, tree)
5. Configures NFS storage for ISO images, backups, and templates
6. Sets up automated backup jobs via vzdump with email notifications
7. Restarts pvedaemon service to apply changes

**Key variables (encrypted in group_vars):**
- `nas_ip`: NFS server IP address
- `nas_path`: NFS export path
- `mailto`: Email address for backup notifications
- `mailto_user`: Email username
- `mailto_password`: Email password

**Available tags for selective execution:**
```bash
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --tags update  # Only update packages
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --tags nfs     # Only configure NFS
ansible-playbook -i inventory/production/hosts.yml playbooks/pve_post_install.ansible.yml --tags backup  # Only setup backups
```

**Note:** Always restart `pvedaemon.service` after modifying Proxmox configuration to ensure changes take effect.

### Windows Template Provisioning

Two approaches exist for provisioning Windows Server templates. Use the role-based approach (testrole) for new templates; the direct approach is maintained for backward compatibility.

#### `testrole.ansible.yml` - Role-Based Template Provisioning (Recommended)
Modern modular approach that invokes the `windowstemplate` role. Supports CloudInit-based provisioning.

```bash
ansible-playbook -i inventory/test/hosts.yml playbooks/testrole.ansible.yml
```

**Execution steps (defined in role tasks):**
1. `01-define-vmid.ansible.yml`: Determines next available VMID (avoids collisions)
2. `02-download-iso.ansible.yml`: Downloads Windows Server ISO if not present
3. `03-prepare-files.ansible.yml`: Prepares provisioning ISO with drivers and answer file
4. `04-create-vm.ansible.yml`: Creates Proxmox VM with CloudInit drive (`--ide2 local:cloudinit`)
5. `05-cleanup.ansible.yml`: Removes temporary ISO preparation files

**Key differences from legacy approach:**
- Includes CloudInit drive for modern guest initialization
- Better modularization for testing individual steps
- More robust VMID handling

#### `provision-template.ansible.yml` - Legacy Direct Approach
Direct playbook approach for Windows template provisioning. Maintained for backward compatibility but not recommended for new deployments.

```bash
ansible-playbook -i inventory/test/hosts.yml playbooks/provision-template.ansible.yml
```

**Execution steps:**
1. Generates semi-random, idempotent VMID using hostname and template name as seed
2. Creates temporary directory for ISO preparation
3. Templates `autounattend.xml` Windows answer file
4. Builds custom provisioning ISO with drivers and scripts using `genisoimage`
5. Creates VM with two CD drives (OS ISO + provisioning ISO)
6. Waits for automated Windows installation and sysprep (up to 120 minutes)
7. Converts VM to template and cleans up temporary files

**Key limitation:** No CloudInit drive, relies on traditional CD-based provisioning.

### Test Environment

#### `test.ansible.yml` - Windows Test Environment Setup
Configures the test Windows VMs (dsclab group: srvdc01, srvfile01, srvdsc01) with Active Directory domain, updates, and Windows features.

```bash
ansible-playbook -i inventory/test/hosts.yml playbooks/test.ansible.yml
```

**What it does:**
- Renames servers to match inventory hostnames
- Installs Windows updates with automatic reboot
- Configures Active Directory domain membership
- Installs specified Windows Server features (DNS, DHCP, etc.)
- Manages firewall rules
- Demonstrates Windows modules (`win_hostname`, `win_updates`, `win_feature`, `microsoft.ad.domain`)

**Use cases:**
- Initial setup of test lab infrastructure
- Validating Windows modules before running on production
- Testing Active Directory integration
- Adding new Windows hosts to test environment

## Windows Template Configuration

### Template Variables (`vars/wintpl.yml`)

Critical configuration file for Windows template creation. Key variables:

- **`template_name`**: Template identifier (e.g., "2022-tpl", "2019-tpl")
- **`os_iso_location`**: Path to Windows Server ISO in Proxmox (format: `storage:iso/filename.iso`)
- **`deploy_image`**: Exact Windows edition from answer file (e.g., "Windows Server 2022 SERVERDATACENTER", "Windows Server 2019 SERVERSTANDARD")
- **`vm_cores`**, **`vm_sockets`**, **`vm_memory`**: VM resource specifications in MB
- **`pve_storage_id`**: Proxmox storage target (e.g., "local-lvm" for LVM, "local" for file-based)
- **`format`**: Disk format - use "raw" for LVM-backed storage, "qcow2" for file-based storage
- **`agent`**: QEMU guest agent configuration string

**Valid `deploy_image` options:**
```
# Windows Server 2022
Windows Server 2022 SERVERSTANDARDCORE
Windows Server 2022 SERVERDATACENTERCORE
Windows Server 2022 SERVERSTANDARD
Windows Server 2022 SERVERDATACENTER

# Windows Server 2019
Windows Server 2019 SERVERSTANDARDCORE
Windows Server 2019 SERVERDATACENTERCORE
Windows Server 2019 SERVERSTANDARD
Windows Server 2019 SERVERDATACENTER
```

## Understanding the codebase

### Windows Template Role Structure

The `windowstemplate` role (`ansible/roles/windowstemplate/`) is responsible for creating Windows Server VM templates on Proxmox. It's broken into modular task files for flexibility:

**Task Files (in `tasks/`):**
- **01-define-vmid.ansible.yml**: Calculates next available VMID to avoid collisions using seeded random generation
- **02-download-iso.ansible.yml**: Downloads Windows Server ISO from Microsoft (cached, reuses existing ISO)
- **03-prepare-files.ansible.yml**: Generates `autounattend.xml` answer file and creates custom provisioning ISO with VirtIO drivers
- **04-create-vm.ansible.yml**: Creates VM on Proxmox with CloudInit drive and boots from OS ISO
- **05-cleanup.ansible.yml**: Removes temporary files (answer file, provisioning ISO) after VM creation

**Support Files:**
- **templates/autounattend.xml.tpl**: Jinja2 template for Windows unattended answer file (controls installation and sysprep)
- **files/iso-files/**: Contains VirtIO drivers, PowerShell scripts, and Cloudbase-Init configuration
- **vars/main.yml**: Role variable defaults

**How It Works:**
1. Role is called from `testrole.ansible.yml` playbook with variables from `vars/wintpl.yml`
2. Each task file can be run independently or as part of the full sequence
3. The role waits for Windows installation to complete by monitoring VM shutdown (sysprep triggers shutdown)
4. VM is converted to template after installation completes
5. All temporary ISO/answer files are cleaned up automatically

### Inventory Organization

The inventory uses a dual-environment structure:
- **production/**: Single Proxmox host (`pve1`) - used for production VM templates
- **test/**: Proxmox host + Windows test VMs (`srvdc01`, `srvfile01`, `srvdsc01` in `dsclab` group)

This separation prevents accidental production changes and allows independent test environment configuration. Host variables and group variables are encrypted with Ansible Vault for security.

### Proxmox CloudInit Compatibility Patches

The repository patches Proxmox Perl modules to enable Windows CloudInit compatibility:
- **Cloudinit.pm**: Modified to handle Windows CloudInit initialization
- **Qemu.pm**: Modified to properly configure CloudInit drives for Windows VMs

These patches are deployed by `pve_post_install.ansible.yml` to `/usr/share/perl5/PVE/` and require a `pvedaemon.service` restart to take effect.

### Windows VirtIO Drivers

The provisioning role includes VirtIO drivers for optimal Windows VM performance:
- Drivers are bundled in the custom provisioning ISO
- Supports both Server 2019 and Server 2022
- Essential for:
  - Network device performance (network adapter)
  - Storage device performance (SATA/SCSI controllers)
  - Balloon memory management
  - Serial/virtio-console device support

## Important Notes

### Proxmox Considerations

- The repository patches Proxmox Perl modules to enable Windows CloudInit compatibility
- Always restart `pvedaemon.service` after modifying Proxmox configuration files
- VM creation uses `qm` (QEMU Manager) commands directly rather than Ansible modules
- VMID generation uses seeded random numbers to ensure idempotency across runs

### Windows Template Provisioning Workflow

- **Duration**: 60-120 minutes depending on Windows version and updates
- **Progress monitoring**: The `qm wait` command monitors VM shutdown to detect completion
- **Storage location**: ISO files stored in NFS share (`nas-iso`) or local Proxmox storage
- **VirtIO drivers**: Must be available in provisioning ISO for optimal performance
- **Automated setup**: The `autounattend.xml` answer file fully automates Windows installation
- **Sysprep**: Automatically runs after installation to prepare for template cloning

### Ansible Configuration

- **`interpreter_python=auto_silent`**: Automatically detects Python interpreter on target systems
- **`host_key_checking=False`**: Disabled for homelab convenience (recommend re-enabling for production)
- **Parallel forks**: Set to 10 for reasonable parallelization
- **Callbacks enabled**: Debug output with performance profiling (timer, profile_tasks)

## Common Development Patterns

### Testing Before Production

The typical workflow for changes:
1. Make playbook edits
2. Lint with `ansible-lint playbooks/` to catch issues early
3. Test against test environment: `-i inventory/test/hosts.yml`
4. Use `--check` mode for dry-run verification
5. Review output with `-vv` or `-vvv` for detailed debugging
6. Run against production once validated: `-i inventory/production/hosts.yml`

### Creating a New Role

Roles are organized in `ansible/roles/`. To create a new role:

```bash
# Generate role structure
ansible-galaxy role init roles/myrole

# Role structure:
# roles/myrole/
# ├── tasks/main.yml        # Role tasks
# ├── handlers/main.yml      # Event handlers
# ├── templates/             # Jinja2 templates
# ├── files/                 # Static files to copy
# ├── vars/main.yml          # Role default variables
# ├── defaults/main.yml      # Role default variables (lower precedence)
# ├── meta/main.yml          # Role metadata and dependencies
# └── README.md              # Role documentation
```

**Guidelines:**
- Keep tasks focused and modular (break into subtasks files if large)
- Use meaningful task names for readability in playbook output
- Prefix templates with role name when generic (e.g., `myrole-config.j2`)
- Document required variables in `defaults/main.yml` with comments
- Tag tasks for selective execution (e.g., `--tags config`, `--tags install`)

### Developing a New Playbook

Playbooks should be in `ansible/playbooks/`:

```yaml
---
- name: Descriptive playbook name
  hosts: target_group  # Must match inventory group
  gather_facts: true   # Set to false if not needed for performance
  vars:
    # Playbook-specific variables
    my_var: value
  tasks:
    - name: Task description
      module_name:
        param: value
      tags: feature-tag  # Allows selective execution
```

**Naming convention:**
- Use descriptive names: `provision-template.ansible.yml`, `pve_post_install.ansible.yml`
- Keep filenames lowercase with hyphens or underscores
- Suffix with `.ansible.yml` to identify as Ansible playbooks
- Group related playbooks (e.g., all Proxmox playbooks in one directory)

### Adding New Hosts

To add a new host to an environment:
1. Edit `inventory/{env}/hosts.yml` to define the host
2. Create `inventory/{env}/host_vars/{hostname}.yml` for host-specific variables (if needed)
3. Run ping playbook to verify connectivity
4. Test connectivity with verbose output: `ansible-playbook ... -vv`

### Modifying Templates

To create a new Windows Server template version:
1. Update `vars/wintpl.yml` with new `template_name`, `os_iso_location`, and `deploy_image`
2. Ensure ISO file is available in specified location
3. Run `testrole.ansible.yml` (or `provision-template.ansible.yml` if needed)
4. Monitor progress with `qm list` on Proxmox host
5. Validate template after sysprep completion

### Git Workflow

The repository uses `main` as the primary branch with `docker-configuration` for devcontainer changes. When making changes:

1. Create a feature branch for development: `git checkout -b feature/description`
2. Test changes thoroughly in test environment before committing
3. Lint all playbooks: `ansible-lint playbooks/`
4. Commit with descriptive messages: `git commit -m "Describe change and rationale"`
5. Verify no vault passwords or secrets are included: `git diff HEAD`
6. Push to remote and create a pull request for review
7. After merging to main, verify production changes in a dry-run before applying

**Important:** Always use the correct inventory for testing:
- Feature development and validation: use `-i inventory/test/hosts.yml`
- Production deployment: use `-i inventory/production/hosts.yml` (only after validation)

## Troubleshooting

### Ansible Vault Issues

**Problem: "ERROR! Decryption failed"**
- Ensure `.vault_password` file exists and contains correct password
- Or run with `--ask-vault-pass` and enter password interactively
- Check that `ANSIBLE_VAULT_PASSWORD_FILE` environment variable is set correctly

**Problem: Cannot edit vault files**
- Ensure editor is set in `$EDITOR` environment variable
- Try explicitly: `EDITOR=vim ansible-vault edit inventory/production/group_vars/pve.yml`

### Connectivity Issues

**Problem: "SSH timeout" or "WinRM connection refused"**
- Run ping playbook first to identify the issue: `ansible-playbook ... playbooks/ping.ansible.yml -vvv`
- Verify host is reachable: `ping <host-ip>` or `ssh <host>`
- Check SSH service is running on Proxmox: `systemctl status ssh`
- Check WinRM is enabled on Windows: `winrm quickconfig` (run as Administrator)
- Verify firewall rules allow SSH (port 22) and WinRM (port 5985/5986)

**Problem: "Incorrect inventory path"**
- Always verify `-i` path is correct before running
- Production should use: `-i inventory/production/hosts.yml`
- Test should use: `-i inventory/test/hosts.yml`
- Use `--limit localhost` to test locally without infrastructure

### Windows Template Provisioning Issues

**Problem: "VMID collision" or "VM already exists"**
- Check existing VMs on Proxmox: `qm list`
- Ensure `template_name` is unique in `vars/wintpl.yml`
- Remove conflicting VM if safe: `qm destroy {vmid}`

**Problem: "ISO not found" error**
- Verify `os_iso_location` path exists on Proxmox in specified storage
- Format must be: `storage:iso/filename.iso`
- Example: `nas-iso:/Server2022_Datacenter.iso` or `local:iso/Server2022.iso`

**Problem: "autounattend.xml template error"**
- Ensure `deploy_image` matches exactly one option in Windows ISO
- Verify ISO is a valid Windows Server installation media
- Check answer file syntax with test run: `ansible-lint`

**Problem: Template creation hangs or times out**
- Monitor VM progress on Proxmox: `qm status {vmid}` or `qm wait {vmid}`
- Check VM console for Windows installation errors
- Windows updates can take 30+ minutes; be patient with 2-hour timeouts
- If truly hung, check disk space on Proxmox storage

### Python/Dependency Issues

**Problem: "ansible: command not found"**
- Ensure direnv is installed: `direnv --version`
- Ensure `.envrc` file exists and is allowed: `direnv allow`
- Run `make -C ansible prepare` to reinstall dependencies
- Check Python venv: `source .direnv/python-*/bin/activate`

**Problem: "module not found" for Ansible collections**
- Reinstall Galaxy dependencies: `ansible-galaxy install -fr requirements.yml --force`
- Check installation: `ansible-galaxy list`
- Verify `ANSIBLE_COLLECTIONS_PATH` is set by direnv

**Problem: "pywinrm not installed"**
- Rebuild environment: `make -C ansible prepare`
- Manually install: `python -m pip install pywinrm>=0.2.2`
- This is required for Windows connectivity via WinRM

### Performance Issues

**Problem: "Playbook running very slowly"**
- Check parallel forks limit: Should be 10 by default in `.envrc`
- Increase if stable: `export ANSIBLE_FORKS=20`
- Use `-vv` to identify which task is slow

**Problem: "High CPU/Memory on Proxmox during template creation"**
- Windows Updates during installation consume significant resources
- Monitor with `top` on Proxmox
- Ensure adequate free disk space: `df -h`
- This is normal and expected during 60-120 minute template creation
