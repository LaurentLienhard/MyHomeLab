# Roadmap - Ajouter des Ressources Progressivement

Cette roadmap explique comment ajouter progressivement des configurations à Terraform, en commençant par les plus simples jusqu'aux plus complexes.

## 🎯 Philosophie

**Petits pas importants**: Ne configurer qu'une ressource à la fois, tester, valider, puis progresser.

```
Configuration Minimale
       ↓ (terraform init + apply)
Connexion Validée
       ↓
Ajouter Stockage NFS
       ↓
Ajouter Sauvegardes
       ↓
Ajouter Certificats SSL
       ↓
Ajouter Utilisateurs
       ↓
Provisioner VMs
       ↓
Complet!
```

## Phase 1: ✅ Configuration Minimale (Actuelle)

**Objectif**: Se connecter à Proxmox sans rien faire

**Fichiers modifiés**:
- `main.tf` - Juste la lecture du nœud

**Commandes**:
```bash
make init
make apply
```

**Résultat**:
```
proxmox_target_node = {
  "name" = "pve1"
  "status" = "online"
  "version" = "8.1.x"
  ...
}
```

✅ **Étape actuelle** - Vous êtes là!

---

## Phase 2: 📦 Ajouter du Stockage NFS (Recommandé ensuite)

**Durée estimée**: 30 minutes

**Prérequis**:
- [ ] Phase 1 complétée et validée
- [ ] Serveur NFS accessible (`192.168.1.252`)
- [ ] Exports NFS configurés sur le NAS (`/volume1/nas-iso`, `/volume1/nas-backup`, `/volume1/nas-template`)

**Étapes**:

### 1. Ajouter les variables NFS

Dans `variables.tf`, les variables sont déjà déclarées:
```hcl
variable "nfs_server_ip" { ... }
variable "nfs_export_base" { ... }
```

### 2. Fournir les valeurs

```bash
# Option A: Variables d'environnement
export TF_VAR_nfs_server_ip="192.168.1.252"
export TF_VAR_nfs_export_base="/volume1"

# Option B: Éditer .env.local
vim .env.local
# Décommenter:
# export TF_VAR_nfs_server_ip="192.168.1.252"
source .env.local
```

### 3. Ajouter la ressource dans main.tf

```hcl
# ============================================================================
# Stockage NFS
# ============================================================================

resource "proxmox_virtual_environment_storage" "nfs_iso" {
  datastore_id = "nas-iso"
  type         = "nfs"
  content      = ["iso"]
  nodes        = [var.proxmox_node_name]
  disable      = false

  nfs {
    server = var.nfs_server_ip
    export = "${var.nfs_export_base}/nas-iso"
  }
}

resource "proxmox_virtual_environment_storage" "nfs_backup" {
  datastore_id = "nas-backup"
  type         = "nfs"
  content      = ["backup"]
  nodes        = [var.proxmox_node_name]
  disable      = false

  nfs {
    server = var.nfs_server_ip
    export = "${var.nfs_export_base}/nas-backup"
  }
}

resource "proxmox_virtual_environment_storage" "nfs_template" {
  datastore_id = "nas-template"
  type         = "nfs"
  content      = ["images", "rootdir"]
  nodes        = [var.proxmox_node_name]
  disable      = false

  nfs {
    server = var.nfs_server_ip
    export = "${var.nfs_export_base}/nas-template"
  }
}
```

### 4. Valider et appliquer

```bash
# Voir les changements
make plan

# Appliquer
make apply
```

### 5. Vérifier dans Proxmox

```bash
# SSH à Proxmox
ssh root@pve1

# Vérifier les mounts
mount | grep nfs

# Vérifier dans l'API
pvesm status

# Ou dans la Web UI:
# Datacenter → Storage
```

✅ **Résultat attendu**: 3 stockages NFS visibles dans Proxmox

---

## Phase 3: 💾 Ajouter les Sauvegardes

**Durée estimée**: 20 minutes (après Phase 2)

**Prérequis**:
- [ ] Phase 2 (stockage NFS) complétée
- [ ] Adresse email pour notifications
- [ ] (Optionnel) SMTP configuré

**Ressource à ajouter dans main.tf**:

```hcl
resource "proxmox_virtual_environment_backup_job" "daily" {
  schedule = "0 21 * * *"  # 21h00 tous les jours
  nodes    = [var.proxmox_node_name]
  storage  = "nas-backup"

  retention {
    keep_daily   = 7
    keep_monthly = 1
  }

  compression = "zstd"
  enabled     = true
  comment     = "Managed by Terraform"
}
```

---

## Phase 4: 🔐 Ajouter un Certificat SSL

**Durée estimée**: 15 minutes (optionnel)

**Prérequis**:
- [ ] Certificat SSL valide (Let's Encrypt, self-signed, etc.)
- [ ] Domaine valide (ex: pve1.example.com)

**Ressource**:

```hcl
resource "proxmox_virtual_environment_certificate" "custom" {
  node_name   = var.proxmox_node_name
  certificate = file("${path.module}/certs/cert.pem")
  private_key = file("${path.module}/certs/key.pem")
  force       = true  # Attention: remplace le certificat existant
}
```

---

## Phase 5: 👥 Ajouter des Utilisateurs

**Durée estimée**: 10 minutes (optionnel)

**Prérequis**:
- [ ] Plan des utilisateurs défini

**Ressource**:

```hcl
resource "proxmox_virtual_environment_user" "terraform" {
  user_id = "terraform@pve"
  password = "STRONG_PASSWORD"
  comment  = "Service account for Terraform"
}

resource "proxmox_virtual_environment_role" "terraform_role" {
  role_id    = "Terraform"
  privileges = [
    "Sys.Audit",
    "Datastore.AllocateSpace",
    "VM.Allocate",
    "VM.Clone",
    "VM.Config.CDROM",
    "VM.Config.Cloudinit",
    # ... autres permissions
  ]
}
```

---

## Phase 6: 🖥️ Provisionner une VM

**Durée estimée**: 1h (plus complexe)

**Prérequis**:
- [ ] Template Windows disponible (provisioner avec Ansible d'abord)
- [ ] Ou ISO Linux avec cloud-init
- [ ] Réseau configuré

**Exemple (Linux)**:

```hcl
resource "proxmox_virtual_environment_vm" "ubuntu" {
  node_name = var.proxmox_node_name

  vm_id   = 100
  name    = "ubuntu-01"

  initialization {
    user_account = {
      username = "ubuntu"
      password = "changeme"
    }
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:snippets/ubuntu-cloud-init.yml"
    size         = 50
  }

  cpu {
    type = "x86-64-v2-AES"
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

  clone {
    vm_id = 9000  # Template Linux ID
  }
}
```

---

## Commandes pour Chaque Phase

### Avant chaque changement

```bash
# Voir ce qui va changer
make plan

# Copier la sortie pour validation
make plan > plan.txt
```

### Pour appliquer

```bash
# Appliquer les changements
make apply
```

### Pour revenir en arrière (DANGER)

```bash
# Détruire les ressources
# ⚠️ Attention: cela supprimera les ressources de Proxmox!
make destroy
```

### Pour valider

```bash
# Sur Proxmox
ssh root@pve1 "pvesm status"         # Vérifier stockage
ssh root@pve1 "qm list"              # Lister VMs
ssh root@pve1 "cat /etc/pve/jobs.cfg" # Vérifier sauvegardes
```

---

## Conseils Pratiques

### 1. Valider à Chaque Étape

```bash
# Après chaque modification:
make validate   # Syntaxe OK?
make plan       # Changements attendus?
make apply      # Appliquer
make output     # Vérifier le résultat
```

### 2. Versionner le Code

```bash
# Committer la configuration (pas les secrets!)
git add *.tf Makefile SETUP.md
git status  # Vérifier que .env.local et tfvars ne sont pas inclus
git commit -m "Add NFS storage configuration"
```

### 3. Documenter les Changements

```hcl
# Dans main.tf, ajouter des commentaires:
# Phase 2: Stockage NFS
# Ajouté le: YYYY-MM-DD
# Raison: Nécessaire pour ISOs, backups, templates
resource "proxmox_virtual_environment_storage" "nfs_iso" {
  # ...
}
```

---

## Timeline Recommandée

| Phase | Durée | Avant | Après |
|-------|-------|-------|-------|
| 1: Minimale | 5 min | Rien | Connexion validée |
| 2: NFS | 30 min | Phase 1 | Stockage opérationnel |
| 3: Backups | 20 min | Phase 2 | Sauvegardes automatiques |
| 4: SSL | 15 min | Phase 2 | HTTPS en production |
| 5: Utilisateurs | 10 min | Phase 1 | Accès multiutilisateur |
| 6: VMs | 60 min | Phase 2 | Infrastructure complète |
| **Total** | **2.5h** | | **Proxmox opérationnel** |

---

## Ressources Documentation

Pour chaque phase, consulter:

- **Provider Proxmox**: https://registry.terraform.io/providers/bpg/proxmox/latest
- **Terraform Docs**: https://www.terraform.io/docs
- **Proxmox API**: https://pve.proxmox.com/pve-docs/api-viewer/

---

## Questions Courantes

### Q: Puis-je revenir en arrière?

**R**: Oui! Soit:
1. Supprimer la ressource de `main.tf` et lancer `terraform apply`
2. Ou utiliser `terraform destroy` pour tout supprimer

### Q: Quand lancer `make apply` vs `make plan`?

**R**:
- Toujours lancer `make plan` d'abord pour voir les changements
- Vérifier que c'est attendu
- Puis `make apply` pour vraiment modifier

### Q: Et si j'ai fait une erreur?

**R**: Ne pas paniquer!
```bash
# Voir l'erreur
make plan

# Corriger la syntaxe dans les fichiers .tf
vim main.tf

# Réessayer
make validate
make plan
make apply
```

### Q: Comment tester sans risque?

**R**: Utiliser `terraform plan` qui ne fait aucune modification.

---

## Prochaine Étape

Vous êtes actuellement à la **Phase 1: Configuration Minimale**.

Pour avancer:
1. ✅ Validez que `make apply` affiche l'état de Proxmox
2. ✅ Consultez [SETUP.md](./SETUP.md) si vous avez des questions
3. ✅ Progressez à Phase 2 (Stockage NFS) quand prêt

**Bonne chance! 🚀**
