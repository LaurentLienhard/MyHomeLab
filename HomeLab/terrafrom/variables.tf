# ============================================================================
# VARIABLES PROXMOX - Credentials et Configuration
# ============================================================================
#
# Ces variables SENSIBLES doivent être fournies via:
# 1. Variables d'environnement: export TF_VAR_proxmox_api_token="..."
# 2. Fichier terraform.tfvars (à .gitignore)
# 3. Terraform Cloud/Enterprise
#
# JAMAIS dans le code ou commentaires!
# ============================================================================

variable "proxmox_url" {
  description = "URL de l'API Proxmox (https://host:8006)"
  type        = string

  # Exemple:
  # default = "https://pve1.example.com:8006"
  # Ou via env: export TF_VAR_proxmox_url="https://pve1.example.com:8006"
}

variable "proxmox_api_token" {
  description = "Token API Proxmox (SENSIBLE - use environment variables!)"
  type        = string
  sensitive   = true

  # Format: user@realm!tokenname=uuid
  # Exemple: root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  #
  # Comment obtenir:
  # 1. Web UI Proxmox: Datacenter → Permissions → API Tokens
  # 2. Cliquer "Add"
  # 3. Remplir User (root@pam) et Token Name (terraform)
  # 4. Cliquer "Generate"
  # 5. Copier le token (montré une seule fois)
  #
  # Fournir via:
  # export TF_VAR_proxmox_api_token="root@pam!terraform=xxxxx"
}

variable "proxmox_insecure" {
  description = "Désactiver vérification certificat TLS (pour certificats auto-signés)"
  type        = bool
  default     = true

  # Pour HOMELAB uniquement!
  # En production: mettre à false avec certificat valide
  # Générer certificat: certbot, Let's Encrypt, ou self-signed signé
}

variable "ssh_username" {
  description = "Utilisateur SSH pour accès à l'hôte Proxmox"
  type        = string
  default     = "root"

  # Peut être: root, ou autre utilisateur avec droits sudo
}

# ============================================================================
# VARIABLES PROXMOX - Configuration Générale
# ============================================================================

variable "proxmox_node_name" {
  description = "Nom du nœud Proxmox (hostname)"
  type        = string
  default     = "pve1"

  # Vérifier avec: hostname sur l'hôte Proxmox
  # Ou dans Proxmox UI: Datacenter → Nodes
}

variable "proxmox_cluster_name" {
  description = "Nom du cluster Proxmox"
  type        = string
  default     = "homelab-cluster"
}

# ============================================================================
# VARIABLES OPTIONNELLES - À UTILISER PLUS TARD
# ============================================================================
#
# Ces variables sont déclarées ici pour la structure,
# mais ne sont pas utilisées pour l'instant.
# Vous pourrez les utiliser pour configurer progressivement:
# - Stockage NFS
# - Configurations de sauvegarde
# - Templates Windows
# - VMs
#

variable "nfs_server_ip" {
  description = "Adresse IP du serveur NFS (optionnel - à configurer plus tard)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "nfs_export_base" {
  description = "Chemin de base des exports NFS (ex: /volume1)"
  type        = string
  default     = "/volume1"
}

variable "backup_email" {
  description = "Email pour notifications de sauvegarde (optionnel)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "environment" {
  description = "Nom de l'environnement (dev, test, prod)"
  type        = string
  default     = "homelab"

  validation {
    condition     = contains(["dev", "test", "staging", "prod", "homelab"], var.environment)
    error_message = "Environment doit être: dev, test, staging, prod, ou homelab"
  }
}

variable "tags" {
  description = "Tags à appliquer aux ressources"
  type        = map(string)
  default = {
    Environment = "homelab"
    ManagedBy   = "terraform"
    Project     = "MyHomeLab"
  }
}
