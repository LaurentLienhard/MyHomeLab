# ============================================================================
# Configuration Proxmox - MINIMALISTE (aucune configuration)
# ============================================================================
#
# Ce fichier se connecte simplement à Proxmox et récupère des informations
# SANS modifier quoi que ce soit.
#
# Prêt pour ajouter progressivement des ressources.
# ============================================================================

# Récupérer les informations du nœud Proxmox
data "proxmox_nodes" "available" {
  # Liste tous les nœuds du cluster Proxmox
  # Résultat stocké dans proxmox_nodes.available.nodes
}

# Récupérer les informations détaillées du nœud cible
data "proxmox_node" "pve" {
  node_name = var.proxmox_node_name
}

# ============================================================================
# RESSOURCES - À AJOUTER PROGRESSIVEMENT
# ============================================================================
#
# Ci-dessous sont les ressources que vous pourrez ajouter plus tard.
# Pour l'instant, commentées pour éviter toute modification accidentelle.
#
# Décommenter et remplir au fur et à mesure:
#
# 1. Stockage NFS:
#    resource "proxmox_virtual_environment_storage" "nfs_iso" { ... }
#
# 2. Sauvegarde:
#    resource "proxmox_virtual_environment_backup_job" "daily" { ... }
#
# 3. Certificat SSL:
#    resource "proxmox_virtual_environment_certificate" "custom" { ... }
#
# 4. Utilisateur/Permissions:
#    resource "proxmox_virtual_environment_user" "terraform" { ... }
#
# 5. Templates Windows (via Ansible + Terraform):
#    resource "null_resource" "windows_template" { ... }
#
# 6. VMs:
#    resource "proxmox_virtual_environment_vm" "example" { ... }
#
# ============================================================================
