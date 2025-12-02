# 📚 Index - Terraform Proxmox

Guide de navigation pour la configuration Terraform du projet MyHomeLab.

## 🎯 Pour Démarrer (Lisez d'abord!)

### 1. **[README.md](./README.md)** - Vue d'ensemble
   - Objectif et philosophie
   - Quick start 3 minutes
   - Structure des fichiers
   - Commandes principales

### 2. **[SETUP.md](./SETUP.md)** - Configuration initiale (PAS À PAS)
   - ✅ Créer un API token Proxmox
   - ✅ Configurer les variables
   - ✅ Tester la connexion
   - ✅ Résolution des problèmes

**→ Commencez par SETUP.md!**

---

## 🗺️ Pour Progresser

### **[ROADMAP.md](./ROADMAP.md)** - Phases de développement
   - **Phase 1**: Configuration minimale ✅ (Actuelle)
   - **Phase 2**: Stockage NFS (Recommandée ensuite)
   - **Phase 3**: Sauvegardes automatiques
   - **Phase 4**: Certificat SSL
   - **Phase 5**: Utilisateurs et permissions
   - **Phase 6**: VMs Linux/Windows

---

## 📁 Fichiers Terraform

### Configuration (à utiliser)
| Fichier | Rôle |
|---------|------|
| `terraform.tf` | Version + Backend |
| `provider.tf` | Configuration Proxmox |
| `variables.tf` | Déclaration des variables |
| `main.tf` | Ressources (vide maintenant) |
| `outputs.tf` | Affichage des résultats |

### Configuration Sécurisée (à personnaliser)
| Fichier | Usage |
|---------|-------|
| `.env.template` | Copier en `.env.local` (variables d'env) |
| `terraform.tfvars.template` | Copier en `terraform.tfvars` (fichier) |
| `.gitignore` | Protège les secrets |

### Utilitaires
| Fichier | Rôle |
|---------|------|
| `Makefile` | Commandes faciles (make init, make apply, etc.) |
| `examples.tf.disabled` | Exemples de ressources à décommenter |

---

## 🔐 Gestion des Credentials

**Trois options disponibles** (choisir une):

```bash
# Option 1: Variables d'environnement (meilleure pour CI/CD)
export TF_VAR_proxmox_url="https://pve1.example.com:8006"
export TF_VAR_proxmox_api_token="root@pam!terraform=..."

# Option 2: Fichier .env.local (meilleure pour développement)
cp .env.template .env.local
vim .env.local
source .env.local

# Option 3: Fichier terraform.tfvars (local seulement)
cp terraform.tfvars.template terraform.tfvars
vim terraform.tfvars
```

⚠️ **IMPORTANT**: `.env.local` et `terraform.tfvars` sont dans `.gitignore` - jamais commités!

---

## ⚡ Commandes Principales

```bash
cd HomeLab/terrafrom

# Configuration
make setup              # Afficher le guide
make check-env         # Vérifier les variables

# Terraform
make init              # Initialiser (une fois)
make validate          # Vérifier la syntaxe
make plan              # Voir les changements (sans appliquer)
make apply             # Appliquer la configuration
make output            # Voir l'état de Proxmox

# Maintenance
make state-list        # Ressources gérées
make refresh           # Synchroniser l'état
make clean             # Nettoyer les fichiers temp
make help              # Voir toutes les commandes
```

---

## 🚀 Workflow Typique

### Premier Démarrage:
```bash
# 1. Lire SETUP.md et suivre les étapes
cat SETUP.md

# 2. Initialiser Terraform
make init

# 3. Tester la connexion
make plan

# 4. Valider
make apply
make output

# ✅ Si vous voyez l'état de Proxmox: C'est bon!
```

### Ajouter une Ressource:
```bash
# 1. Consulter ROADMAP.md pour l'ordre recommandé
cat ROADMAP.md

# 2. Copier le code depuis examples.tf.disabled
cat examples.tf.disabled

# 3. Ajouter dans main.tf
vim main.tf

# 4. Valider et appliquer
make validate
make plan
make apply

# 5. Vérifier dans Proxmox
make output
```

---

## 📖 Documentation Référence

### Terraform
- [Official Docs](https://www.terraform.io/docs)
- [Proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest)

### Proxmox
- [API Documentation](https://pve.proxmox.com/pve-docs/api-viewer/)
- [Official Website](https://www.proxmox.com/)

### Ansible (Integration)
- Voir: `save old stuff/ansible/`
- Utilisé pour: Templates Windows, configuration post-VM

---

## 🛠️ Structure du Projet

```
HomeLab/terrafrom/
│
├── 📄 Fichiers Terraform
│   ├── terraform.tf           # Configuration Terraform
│   ├── provider.tf            # Connexion à Proxmox
│   ├── variables.tf           # Variables déclarées
│   ├── main.tf                # Ressources (actuellement vide)
│   └── outputs.tf             # Affichage des résultats
│
├── 🔐 Configuration Sécurisée
│   ├── .env.template          # Template variables d'env
│   ├── .env.local             # À créer (ignoré par git)
│   ├── terraform.tfvars.template
│   ├── terraform.tfvars       # À créer (ignoré par git)
│   └── .gitignore             # Protège les secrets
│
├── 📚 Documentation
│   ├── INDEX.md               # Ce fichier
│   ├── README.md              # Vue d'ensemble
│   ├── SETUP.md               # Configuration initiale
│   ├── ROADMAP.md             # Phases de développement
│   └── examples.tf.disabled   # Exemples de ressources
│
└── ⚙️ Outils
    └── Makefile               # Commandes pratiques
```

---

## ✅ Checklist d'Installation

- [ ] Lire README.md (5 min)
- [ ] Suivre SETUP.md (10 min)
- [ ] Créer API token Proxmox (2 min)
- [ ] Configurer variables (2 min)
- [ ] `make init` (1 min)
- [ ] `make validate` (✓ ok)
- [ ] `make apply` (✓ affiche état Proxmox)
- [ ] Lire ROADMAP.md (5 min)
- [ ] Prêt pour Phase 2! ✨

**Durée totale: ~30 minutes**

---

## 🆘 Besoin d'Aide?

### Problème?
1. Consulter "Résolution des Problèmes" dans [SETUP.md](./SETUP.md)
2. Vérifier les commandes Terraform: `make help`
3. Lire la documentation du provider

### Question sur une ressource?
1. Voir [ROADMAP.md](./ROADMAP.md) pour les étapes
2. Voir [examples.tf.disabled](./examples.tf.disabled) pour du code
3. Consulter [Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest)

### Credentials?
1. Créer un nouveau token: Proxmox UI → Datacenter → Permissions → API Tokens
2. Exporter ou configurer dans `.env.local`
3. Tester: `make apply`

---

## 🎯 Objectif Final

```
Proxmox Fraîchement Installé
        ↓
   Terraform
        ↓
   Infrastructure-as-Code
        ↓
   Stockage NFS
   Sauvegardes
   Certificats
   Utilisateurs
   VMs
        ↓
   Cluster Proxmox Opérationnel!
```

---

## 📞 Support

Pour des questions ou problèmes:
1. Vérifier la documentation ci-dessus
2. Consulter les logs: `make info` ou `terraform show`
3. Tester la connexion: `make output`

---

## 🎉 Vous êtes Prêt!

**Prochaine étape**: Ouvrir [SETUP.md](./SETUP.md) et suivre le guide pas à pas.

```bash
# Commencez ici:
cat SETUP.md
```

Bonne chance! 🚀
