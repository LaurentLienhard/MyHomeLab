# 🚀 Premier Démarrage - Terraform Proxmox

Guide pas à pas pour votre **première utilisation** de Terraform avec Proxmox fraîchement installé.

## ⏱️ Durée: ~30 minutes

## 📋 Avant de Commencer

- [ ] Proxmox installé et accessible sur `https://pve1.example.com:8006`
- [ ] Accès root à Proxmox (SSH possible)
- [ ] Terraform 1.0+ installé localement (`terraform --version`)
- [ ] 30 minutes de temps libre (pas besoin d'être expert!)

## 🎬 Démarrage (Étape par Étape)

### Étape 1: Créer un API Token (2 minutes)

**Sur l'interface Web Proxmox:**

```
1. Aller à: https://pve1.example.com:8006
2. Login avec root/password
3. Cliquer: Datacenter → Permissions → API Tokens
4. Cliquer: Add
5. Remplir:
   - User: root@pam
   - Token Name: terraform
   - Privilege Separation: [ ] (décoché)
6. Cliquer: Generate
7. 📌 COPIER le token (affiché UNE SEULE FOIS!)

Format du token:
root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

✅ **Token copié?** Continuer.

---

### Étape 2: Se Placer dans le Répertoire (1 minute)

```bash
cd /workspaces/MyHomeLab/HomeLab/terrafrom

# Vérifier qu'on est au bon endroit
pwd
# Devrait afficher: /workspaces/MyHomeLab/HomeLab/terrafrom

# Voir les fichiers
ls -la *.tf
```

✅ **Au bon endroit?** Continuer.

---

### Étape 3: Configurer les Variables (3 minutes)

**Choisir une option (même méthode):**

#### Option A: Variables d'Environnement (Simple)

```bash
export TF_VAR_proxmox_url="https://pve1.homelab.local:8006"
export TF_VAR_proxmox_api_token="root@pam!terraform=YOUR-TOKEN-HERE"
export TF_VAR_proxmox_insecure="true"

# Vérifier
echo $TF_VAR_proxmox_api_token
# Doit afficher votre token
```

#### Option B: Fichier .env.local (Recommandé)

```bash
# Copier le template
cp .env.template .env.local

# Éditer
vim .env.local
# Chercher et remplir:
# - TF_VAR_proxmox_url="https://pve1.homelab.local:8006"
# - TF_VAR_proxmox_api_token="root@pam!terraform=YOUR-TOKEN"
# - TF_VAR_proxmox_insecure="true"

# Sourcer
source .env.local

# Vérifier
echo $TF_VAR_proxmox_api_token
```

✅ **Variables configurées?** Continuer.

---

### Étape 4: Initialiser Terraform (2 minutes)

```bash
# Initialiser
make init

# Ou manuellement:
terraform init

# Vous devez voir:
# Terraform has been successfully configured!
```

✅ **Initialisation OK?** Continuer.

---

### Étape 5: Valider la Configuration (1 minute)

```bash
# Valider la syntaxe
make validate

# Doit afficher:
# Success! The configuration is valid.
```

✅ **Validation OK?** Continuer.

---

### Étape 6: Voir les Changements (Aucun pour l'instant!) (1 minute)

```bash
# Afficher le plan
make plan

# Vous devez voir:
# No changes. Your infrastructure matches the configuration.
# (C'est normal - main.tf ne configure rien pour l'instant)
```

✅ **Plan OK?** Continuer.

---

### Étape 7: Appliquer et Tester (2 minutes)

```bash
# Appliquer la configuration (juste la lecture de l'état)
make apply

# Vous devez voir:
# Apply complete!
```

✅ **Apply OK?** Continuer.

---

### Étape 8: Vérifier la Connexion (2 minutes)

```bash
# Afficher l'état de Proxmox
make output

# Vous devez voir quelque chose comme:
#
# proxmox_connection_info = {
#   "url" = "https://pve1.homelab.local:8006"
#   "node_name" = "pve1"
#   ...
# }
#
# proxmox_target_node = {
#   "name" = "pve1"
#   "status" = "online"
#   "version" = "8.1.x"
#   ...
# }
```

✅ **Connexion validée!** 🎉

---

## 🎉 Félicitations!

Vous avez réussi à:
- ✅ Créer un API token Proxmox
- ✅ Configurer Terraform
- ✅ Initialiser le projet
- ✅ Valider la connexion
- ✅ Afficher l'état de Proxmox

**La configuration minimaliste fonctionne!**

---

## 🚀 Prochaines Étapes

Maintenant que la connexion fonctionne, vous pouvez:

### Immédiatement:
```bash
# Comprendre comment fonctionnent les changements
make plan      # Voir ce qui pourrait changer
# (Actuellement: rien)

# Voir les commandes disponibles
make help      # Affiche tous les targets

# Consulter la documentation
cat ROADMAP.md # Phases de développement
```

### Ensuite:
1. Ajouter progressivement des ressources (voir ROADMAP.md)
2. Commencer par du stockage NFS (plus simple)
3. Progresser vers les sauvegardes, VMs, etc.

---

## ❓ Dépannage Rapide

### "Erreur: Invalid API token format"
```bash
# Vérifier le token
echo $TF_VAR_proxmox_api_token

# Format correct:
# root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#                  ^           ^
#                  ! at the end = after ! is uuid

# Si incorrect: créer un nouveau token dans Proxmox UI
```

### "Erreur: Connection refused"
```bash
# Vérifier que Proxmox est accessible
ping pve1.homelab.local

# Vérifier l'URL
echo $TF_VAR_proxmox_url
# Doit être EXACTEMENT: https://pve1.homelab.local:8006
```

### "Erreur: Node not found"
```bash
# Sur Proxmox, vérifier le hostname
ssh root@pve1 "hostname"

# Mettre à jour la variable
export TF_VAR_proxmox_node_name="pve1"
# (Ou dans .env.local)
```

---

## 💾 Sauvegarder le Configuration

```bash
# Committer les fichiers (pas les secrets!)
git add *.tf Makefile *.md .gitignore
git status  # Vérifier que .env.local n'est PAS affiché
git commit -m "Initial Terraform Proxmox setup"
```

---

## 📚 Prochaine Lecture

**Vous êtes prêt pour:**
- [ROADMAP.md](./ROADMAP.md) - Ajouter des ressources progressivement
- [examples.tf.disabled](./examples.tf.disabled) - Code des ressources

---

## ✨ Fin!

**Vous pouvez maintenant:**
- Ajouter des configurations progressivement
- Voir les changements avec `make plan`
- Appliquer les changements avec `make apply`
- Gérer Proxmox via code!

### Étape suivante recommandée:
**Ajouter du stockage NFS** (voir ROADMAP.md Phase 2)

Bonne chance! 🚀
