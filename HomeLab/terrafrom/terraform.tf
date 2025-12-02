terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }

  # Configuration du backend pour le state
  # Par défaut: fichier local terraform.tfstate
  # Pour remote state (recommandé en production):
  # Décommenter et configurer ci-dessous

  # backend "local" {
  #   path = "terraform.tfstate"
  # }

  # backend "s3" {
  #   bucket         = "my-terraform-state"
  #   key            = "homelab/proxmox/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }

  # backend "remote" {
  #   organization = "my-organization"
  #   workspaces {
  #     name = "homelab-proxmox"
  #   }
  # }
}
