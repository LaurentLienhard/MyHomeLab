# Configuration Terraform pour Proxmox Fraîchement Installé

Ce guide vous aide à configurer Terraform pour se connecter à un **Proxmox fraîchement installé** sans effectuer aucune modification automatique.

## 📋 Pré-requis

### Sur votre machine locale
- [ ] Terraform 1.0+ (`terraform --version`)
- [ ] SSH configuré pour accéder à Proxmox
- [ ] Un terminal

### Sur Proxmox
- [ ] Installation fraîche complétée
- [ ] Accès root possible
- [ ] API accessible sur port 8006

## 🔑 Étape 1: Créer un Token API (2 minutes)

Un token API permet à Terraform de se connecter à Proxmox de manière sécurisée.

### Sur la Web UI Proxmox:

1. Aller à: `https://pve1.example.com:8006`
2. Naviguer: **Datacenter** → **Permissions** → **API Tokens**
3. Cliquer **Add**
4. Remplir:
   - **User**: `root@pam`
   - **Token Name**: `terraform`
   - **Privilege Separation**: Laisser déchecké
5. Cliquer **Generate**
6. **COPIER le token** (affiché une seule fois!)

Format du token:
```
root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

⚠️ **Garder ce token sûr!** Il donne accès complet à Proxmox.

## 🔧 Étape 2: Configurer Terraform (2 minutes)

### Option A: Variables d'Environnement (Simple)

```bash
# CD dans le répertoire terraform
cd HomeLab/terrafrom

# Exporter les variables
export TF_VAR_proxmox_url="https://pve1.homelab.local:8006"
export TF_VAR_proxmox_api_token="root@pam!terraform=YOUR-TOKEN-HERE"
export TF_VAR_proxmox_insecure="true"

# Vérifier
echo $TF_VAR_proxmox_api_token
```

### Option B: Fichier .env.local (Recommandé)

```bash
cd HomeLab/terrafrom

# Copier le template
cp .env.template .env.local

# Éditer avec vos valeurs
vim .env.local

# Sourcer le fichier
source .env.local

# Vérifier
echo $TF_VAR_proxmox_api_token
```

### Option C: Fichier terraform.tfvars (Local)

```bash
cd HomeLab/terrafrom

# Copier le template
cp terraform.tfvars.template terraform.tfvars

# Éditer avec vos valeurs
vim terraform.tfvars
```

⚠️ **Les fichiers `.env.local` et `terraform.tfvars` sont ignorés par git** - ils ne seront jamais commités.

## ✅ Étape 3: Tester la Connexion (1 minute)

```bash
cd HomeLab/terrafrom

# Initialiser Terraform
terraform init

# Valider la configuration
terraform validate

# Afficher les outputs (devrait montrer l'information de connexion)
terraform apply -auto-approve

# Voir le détail
terraform output
```

Attendez-vous à voir quelque chose comme:
```
proxmox_connection_info = {
  "cluster_name" = "homelab-cluster"
  "insecure_mode" = true
  "node_name" = "pve1"
  "ssh_user" = "root"
  "url" = "https://pve1.homelab.local:8006"
}

proxmox_target_node = {
  "cpu" = 0.05
  "memory" = {...}
  "name" = "pve1"
  "status" = "online"
  "uptime" = 12345
  "version" = "8.1.x"
}
```

✓ Si vous voyez cela: **La connexion fonctionne!**

## ⚠️ Résolution des Problèmes

### Erreur: "Invalid API token format"

```bash
# Vérifier le format du token
echo $TF_VAR_proxmox_api_token

# Doit contenir:
# root@pam!terraform=xxxxx
#         ^           ^
#      @ and !

# Si incorrect, recréer un nouveau token dans Proxmox UI
```

### Erreur: "Connection refused"

```bash
# Vérifier que Proxmox est accessible
ping pve1.homelab.local
ssh root@pve1.homelab.local "hostname"

# Vérifier l'URL
echo $TF_VAR_proxmox_url
# Doit être: https://pve1.homelab.local:8006

# Vérifier le port
curl -k https://pve1.homelab.local:8006/api2/json/version
```

### Erreur: "Node not found"

```bash
# Vérifier le nom du nœud
ssh root@pve1 "hostname"

# Mettre à jour la variable
export TF_VAR_proxmox_node_name="pve1"

# Relancer
terraform plan
```

## 🎯 Ce que Terraform Fait (et ne fait pas)

### ✓ CE QUE TERRAFORM FAIT MAINTENANT:
- Se connecte à Proxmox
- Lit les informations du nœud
- Affiche l'état et la configuration
- **RIEN DE PLUS!**

### ✗ CE QUE TERRAFORM NE CONFIGURE PAS ENCORE:
- Pas de stockage NFS
- Pas de sauvegarde
- Pas de certificat SSL
- Pas de VMs
- Aucune modification

## 📝 Prochaines Étapes

Maintenant que la connexion fonctionne, vous pouvez:

### 1. Ajouter du Stockage NFS
Décommenter dans `main.tf`:
```hcl
resource "proxmox_virtual_environment_storage" "nfs_iso" {
  # ...
}
```

### 2. Configurer des Sauvegardes
```hcl
resource "proxmox_virtual_environment_backup_job" "daily" {
  # ...
}
```

### 3. Ajouter des Utilisateurs
```hcl
resource "proxmox_virtual_environment_user" "terraform" {
  # ...
}
```

### 4. Créer des VMs
```hcl
resource "proxmox_virtual_environment_vm" "example" {
  # ...
}
```

**À chaque ajout:**
1. `terraform plan` - voir les changements
2. `terraform apply` - appliquer les changements

## 🛡️ Sécurité

### Protéger les Credentials

```bash
# Ne JAMAIS committer les fichiers sensibles
# Vérifier que .gitignore les exclut:
grep -E "\.env\.local|terraform\.tfvars" .gitignore

# Restreindre les permissions
chmod 600 .env.local
chmod 600 terraform.tfvars

# Vérifier qu'ils ne sont pas commités
git status | grep -E "\.env|tfvars"
# Ne devrait rien afficher
```

### Rotation du Token

Pour changer le token:
1. Créer un nouveau token dans Proxmox UI
2. Mettre à jour la variable `TF_VAR_proxmox_api_token`
3. Supprimer l'ancien token dans Proxmox UI

## 📚 Commandes Terraform Utiles

```bash
# Initialiser
terraform init

# Valider la syntaxe
terraform validate

# Voir les changements à venir
terraform plan

# Appliquer les changements
terraform apply

# Voir l'état actuel
terraform state list

# Voir les détails d'une ressource
terraform state show proxmox_node.pve

# Détruire les ressources (DANGER!)
terraform destroy

# Nettoyer les fichiers temporaires
rm -rf .terraform .terraform.lock.hcl terraform.tfstate*
```

## 🚀 Vous êtes Prêt!

Une fois la connexion validée:

```bash
# Afficher l'état de Proxmox
terraform output

# Savoir que vous pouvez:
# ✓ Ajouter progressivement des configurations
# ✓ Voir les changements avant de les appliquer
# ✓ Revenir en arrière avec terraform destroy
# ✓ Versionner votre infrastructure
```

## 📖 Documentation Complète

Pour plus de détails:
- [Provider Proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Proxmox API](https://pve.proxmox.com/pve-docs/api-viewer/)

## ✨ Prochaine Étape

Une fois ce setup complété avec succès:

1. Consulter `ROADMAP.md` pour configurer progressivement
2. Lire la documentation du provider Proxmox
3. Commencer par du stockage NFS (plus simple)
4. Progresser vers les sauvegardes, puis les VMs

Bonne chance! 🎉
