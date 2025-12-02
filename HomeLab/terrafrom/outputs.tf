# ============================================================================
# Outputs - Information de Connexion et État de Proxmox
# ============================================================================

output "proxmox_connection_info" {
  description = "Information de connexion Proxmox"
  value = {
    url              = var.proxmox_url
    node_name        = var.proxmox_node_name
    insecure_mode    = var.proxmox_insecure
    ssh_user         = var.ssh_username
    cluster_name     = var.proxmox_cluster_name
  }
}

output "proxmox_nodes_available" {
  description = "Liste des nœuds Proxmox disponibles"
  value = try(
    [for node in data.proxmox_nodes.available.nodes : {
      name   = node.name
      status = node.status
      type   = node.type
    }],
    "Erreur: Impossible de lire les nœuds (vérifier credentials)"
  )
}

output "proxmox_target_node" {
  description = "Détails du nœud cible"
  value = try(
    {
      name    = data.proxmox_node.pve.node_name
      status  = data.proxmox_node.pve.status
      uptime  = data.proxmox_node.pve.uptime
      cpu     = data.proxmox_node.pve.cpu
      memory  = data.proxmox_node.pve.memory
      version = data.proxmox_node.pve.version
    },
    "Erreur: Impossible de lire le nœud cible (vérifier nom et credentials)"
  )
}

output "environment" {
  description = "Environnement Terraform"
  value       = var.environment
}

output "next_steps" {
  description = "Prochaines étapes"
  value = [
    "✓ Connexion Proxmox établie!",
    "",
    "Prochaines étapes:",
    "1. Vérifier les informations ci-dessus",
    "2. Consulter QUICKSTART.md pour ajouter progressivement des ressources",
    "3. Décommenter les ressources dans main.tf",
    "4. Lancer 'terraform plan' avant d'appliquer"
  ]
}
