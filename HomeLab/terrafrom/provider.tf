provider "proxmox" {
  # Endpoint API Proxmox
  endpoint = var.proxmox_url

  # Token API pour l'authentification
  api_token = var.proxmox_api_token

  # Mode insécurisé (accepte certificats auto-signés)
  # À mettre à false en production avec certificat valide
  insecure = var.proxmox_insecure

  # Configuration SSH pour les commandes directes sur l'hôte Proxmox
  ssh {
    agent    = true
    username = var.ssh_username
    # La clé privée sera utilisée depuis l'agent SSH ou ~/.ssh/id_rsa
  }

  # Timeout par défaut pour les requêtes API
  # timeout = "300s"
}
