.PHONY: help init validate plan apply destroy output state-list refresh clean setup check-env

.DEFAULT_GOAL := help

TERRAFORM := terraform

help: ## Affiche l'aide
	@echo "Terraform Proxmox - Commandes Disponibles"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Utilisation: make [target]"
	@echo "Exemple: make init && make plan && make apply"
	@echo ""

setup: ## Guide de configuration initial
	@echo "📖 Consultez SETUP.md pour configurer Terraform:"
	@echo ""
	@echo "1. Créer un API token dans Proxmox:"
	@echo "   Datacenter → Permissions → API Tokens → Add"
	@echo ""
	@echo "2. Exporter les variables:"
	@echo "   export TF_VAR_proxmox_url=\"https://pve1.example.com:8006\""
	@echo "   export TF_VAR_proxmox_api_token=\"root@pam!terraform=xxxxx\""
	@echo ""
	@echo "3. Ou copier le template .env:"
	@echo "   cp .env.template .env.local && source .env.local"
	@echo ""
	@echo "4. Initialiser Terraform:"
	@echo "   make init"
	@echo ""

check-env: ## Vérifier les variables d'environnement requises
	@echo "🔍 Vérification des variables Terraform..."
	@if [ -z "$$TF_VAR_proxmox_url" ]; then \
		echo "❌ TF_VAR_proxmox_url non défini"; \
		exit 1; \
	fi
	@if [ -z "$$TF_VAR_proxmox_api_token" ]; then \
		echo "❌ TF_VAR_proxmox_api_token non défini"; \
		exit 1; \
	fi
	@echo "✅ Variables d'environnement OK"
	@echo ""
	@echo "Proxmox URL: $$TF_VAR_proxmox_url"
	@echo "API Token: (masqué pour sécurité)"

init: ## Initialiser Terraform (télécharge le provider)
	@echo "📦 Initialisation de Terraform..."
	$(TERRAFORM) init
	@echo "✅ Initialisation complète"

validate: ## Valider la syntaxe Terraform
	@echo "✔️  Validation de la configuration..."
	$(TERRAFORM) validate
	@echo "✅ Configuration valide"

plan: check-env validate ## Afficher les changements (sans appliquer)
	@echo "📋 Planification des changements..."
	$(TERRAFORM) plan

apply: ## Appliquer la configuration (lit juste l'état Proxmox, rien ne change)
	@echo "⚙️  Application de la configuration..."
	$(TERRAFORM) apply -auto-approve
	@echo "✅ Application complète"
	@echo ""
	@make output

apply-check: ## Voir les changements avant d'appliquer
	@echo "📋 Planification (sans appliquer)..."
	$(TERRAFORM) plan -out=tfplan
	@echo ""
	@echo "Résumé ci-dessus. Pour appliquer:"
	@echo "  terraform apply tfplan"

output: ## Afficher les informations de connexion Proxmox
	@echo "📊 État de la Connexion Proxmox:"
	@echo ""
	$(TERRAFORM) output
	@echo ""

state-list: ## Lister les ressources dans l'état
	@echo "📦 Ressources gérées par Terraform:"
	$(TERRAFORM) state list

state-show: ## Afficher les détails d'une ressource
	@if [ -z "$(RESOURCE)" ]; then \
		echo "Usage: make state-show RESOURCE=data.proxmox_node.pve"; \
		echo ""; \
		echo "Ressources disponibles:"; \
		$(TERRAFORM) state list; \
	else \
		$(TERRAFORM) state show $(RESOURCE); \
	fi

refresh: ## Synchroniser l'état avec Proxmox
	@echo "🔄 Synchronisation de l'état..."
	$(TERRAFORM) refresh
	@echo "✅ État synchronisé"

destroy: ## DANGER: Détruire toutes les ressources gérées
	@echo "⚠️  ATTENTION: Cette commande détruira les ressources"
	@echo "En l'état actuel, il n'y a rien à détruire"
	$(TERRAFORM) destroy

clean: ## Nettoyer les fichiers temporaires
	@echo "🧹 Nettoyage des fichiers temporaires..."
	rm -rf .terraform terraform.tfstate* .terraform.lock.hcl tfplan
	@echo "✅ Nettoyage complète"

fmt: ## Formater les fichiers Terraform
	@echo "🎨 Formatage des fichiers HCL..."
	$(TERRAFORM) fmt -recursive .
	@echo "✅ Formatage complète"

test: init validate plan ## Séquence complète de test (init → validate → plan)
	@echo "✅ Test complète - prêt à appliquer avec 'make apply'"

debug: ## Activer les logs de débogage
	@echo "🐛 Activant mode debug (export TF_LOG=DEBUG)"
	export TF_LOG=DEBUG

version: ## Afficher la version de Terraform
	$(TERRAFORM) version

env-setup: ## Créer .env.local depuis le template
	@if [ -f .env.local ]; then \
		echo ".env.local existe déjà"; \
	else \
		cp .env.template .env.local; \
		chmod 600 .env.local; \
		echo "✅ .env.local créé"; \
		echo "📝 Éditer avec: vim .env.local"; \
		echo "🔗 Sourcer avec: source .env.local"; \
	fi

tfvars-setup: ## Créer terraform.tfvars depuis le template
	@if [ -f terraform.tfvars ]; then \
		echo "terraform.tfvars existe déjà"; \
	else \
		cp terraform.tfvars.template terraform.tfvars; \
		chmod 600 terraform.tfvars; \
		echo "✅ terraform.tfvars créé"; \
		echo "📝 Éditer avec: vim terraform.tfvars"; \
	fi

info: ## Afficher les informations actuelles
	@echo "ℹ️  Informations Terraform"
	@echo ""
	@echo "Version Terraform:"
	@$(TERRAFORM) version | head -1
	@echo ""
	@echo "Répertoire courant: $$(pwd)"
	@echo ""
	@echo "Fichiers Terraform:"
	@ls -lah *.tf 2>/dev/null | tail -n +2 | awk '{print "  " $$9 " (" $$5 ")"}'
	@echo ""
	@echo "Configuration d'état:"
	@if [ -f terraform.tfstate ]; then \
		echo "  ✓ terraform.tfstate existe"; \
	else \
		echo "  ✗ terraform.tfstate manquant (run 'make init')"; \
	fi
	@echo ""

# Commandes non affichées (avancées)
.PHONY: console import

console: ## Ouvrir la console interactive Terraform
	$(TERRAFORM) console

import: ## Importer une ressource existante
	@echo "Usage: make import RESOURCE=proxmox_xxx.name ID=id-value"
	@echo "Example: make import RESOURCE=proxmox_virtual_environment_storage.nfs ID=nas-iso"
	@if [ -n "$(RESOURCE)" ] && [ -n "$(ID)" ]; then \
		$(TERRAFORM) import $(RESOURCE) $(ID); \
	fi
