# Terraform Proxmox - Configuration Minimaliste

Configuration Terraform **minimaliste** pour gérer un serveur Proxmox fraîchement installé, sans effectuer aucune modification automatique.

## 🎯 Objectif

- ✅ Se connecter à Proxmox de manière sécurisée
- ✅ Lire l'état et la configuration de Proxmox
- ✅ Fournir une base pour ajouter progressivement des ressources
- ✅ **RIEN D'AUTRE POUR L'INSTANT**

## 📂 Fichiers

| Fichier | Rôle |
|---------|------|
| `terraform.tf` | Configuration Terraform et backend |
| `provider.tf` | Configuration du provider Proxmox |
| `main.tf` | Ressources (actuellement vide) |
| `variables.tf` | Déclaration des variables |
| `outputs.tf` | Informations affichées après `terraform apply` |
| `SETUP.md` | Guide de configuration initial |

## ⚡ Quick Start (3 min)

```bash
cd HomeLab/terrafrom

# 1. Exporter les variables
export TF_VAR_proxmox_url="https://pve1.example.com:8006"
export TF_VAR_proxmox_api_token="root@pam!terraform=YOUR-TOKEN"
export TF_VAR_proxmox_insecure="true"

# 2. Initialiser
make init

# 3. Tester
make apply
```

## 📖 Guide Complet

Consultez **[SETUP.md](./SETUP.md)** pour:
- Comment créer un API token Proxmox
- Configuration des variables d'environnement
- Résolution des problèmes
- Prochaines étapes

## 🔐 Sécurité

⚠️ **IMPORTANT**: Les credentials Proxmox ne doivent jamais être commités à git!

### Configuration Sécurisée:

**Option 1: Variables d'environnement** (CI/CD)
```bash
export TF_VAR_proxmox_api_token="..."
make apply
```

**Option 2: Fichier .env.local** (Développement)
```bash
cp .env.template .env.local
vim .env.local  # Éditer
source .env.local
make apply
```

**Option 3: Fichier terraform.tfvars** (Local)
```bash
cp terraform.tfvars.template terraform.tfvars
vim terraform.tfvars  # Éditer
make apply
```

Tous ces fichiers sont protégés par `.gitignore` et ne seront jamais commités.

## 📋 Commandes

```bash
# Configuration
make setup          # Afficher le guide de configuration
make check-env      # Vérifier les variables d'environnement

# Terraform
make init           # Initialiser Terraform
make validate       # Valider la syntaxe
make plan           # Afficher les changements (sans appliquer)
make apply          # Appliquer la configuration
make output         # Afficher l'état de Proxmox

# État
make state-list     # Lister les ressources
make state-show     # Afficher les détails d'une ressource

# Maintenance
make refresh        # Synchroniser l'état avec Proxmox
make fmt            # Formater les fichiers HCL
make clean          # Nettoyer les fichiers temporaires
make info           # Afficher les informations
```

## 🚀 Ajouter des Ressources

Pour ajouter une ressource (ex: stockage NFS):

1. **Lire la documentation**: [Provider Proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest)

2. **Ajouter dans main.tf**:
```hcl
resource "proxmox_virtual_environment_storage" "nfs_iso" {
  datastore_id = "nas-iso"
  type         = "nfs"
  content      = ["iso"]
  nodes        = [var.proxmox_node_name]

  nfs {
    server = var.nfs_server_ip
    export = "${var.nfs_export_base}/nas-iso"
  }
}
```

3. **Valider**:
```bash
make validate
make plan
```

4. **Appliquer**:
```bash
make apply
```

## 🔗 Intégration avec Ansible

Après configuration de Proxmox avec Terraform, vous pouvez utiliser Ansible pour:
- Provisioner les templates Windows
- Configurer les VMs
- Gérer les applications

Voir: `save old stuff/ansible/`

## 📚 Documentation Complète

- **[SETUP.md](./SETUP.md)** - Guide de configuration initial
- **[Provider Proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest)** - Documentation officielle
- **[Terraform Docs](https://www.terraform.io/docs)** - Référence Terraform
- **[Proxmox API](https://pve.proxmox.com/pve-docs/api-viewer/)** - API Proxmox

## ✨ Prochaines Étapes

1. ✅ Suivre **[SETUP.md](./SETUP.md)** pour configurer
2. ✅ Valider la connexion avec `make apply`
3. ✅ Ajouter progressivement des ressources:
   - Stockage NFS
   - Sauvegardes
   - Certificats SSL
   - Utilisateurs
   - VMs

## 🛠️ Architecture

```
HomeLab/terrafrom/
├── terraform.tf         # Version + Backend
├── provider.tf          # Provider Proxmox
├── main.tf              # Ressources (vide pour l'instant)
├── variables.tf         # Variables déclarées
├── outputs.tf           # Informations affichées
├── .env.template        # Template variables d'env
├── terraform.tfvars.template # Template tfvars
├── .gitignore           # Protège les secrets
├── Makefile             # Commandes
├── SETUP.md             # Guide de configuration
└── README.md            # Ce fichier
```

## 🆘 Support

En cas de problème, consultez **[SETUP.md](./SETUP.md)** section "Résolution des Problèmes".

## ✅ Checklist de Démarrage

- [ ] API token créé dans Proxmox
- [ ] Variables d'environnement configurées
- [ ] `make init` réussi
- [ ] `make validate` sans erreur
- [ ] `make apply` affiche l'état de Proxmox
- [ ] `terraform output` affiche les informations
- [ ] .env.local / terraform.tfvars dans .gitignore
- [ ] Prêt à ajouter des ressources!

## 📝 Notes

- Cette configuration se connecte à Proxmox mais **ne configure rien par défaut**
- Les ressources sont commentées dans `main.tf` pour éviter les modifications accidentelles
- Vous contrôlez totalement ce qui est créé ou modifié
- Chaque changement doit être approuvé via `terraform plan` et `terraform apply`

---

**Prêt?** → Allez à [SETUP.md](./SETUP.md)
