#!/usr/bin/env bash
set -euo pipefail

# Sincroniza um template oficial do doodba e substitui partes por conteúdos
# do repositório do utilizador, conforme a tua lógica:
# 1) Clona o template oficial (TEMPLATE_REPO)
# 2) Faz backup dos ficheiros originais em `TARGET_DIR` (repos.yaml, addons.yaml,
#    .gitignore, scripts/, private/)
# 3) Clona o repositório do utilizador (USER_REPO)
# 4) Copia os ficheiros selecionados do USER_REPO para TARGET_DIR
# 5) Cria um branch com as alterações e commita+push (opcional)
#
# Segurança: por omissão o script só simula (modo dry-run). Para executar as
# alterações reais passa `--yes`.

usage() {
  cat <<EOF
Usage: $0 [--yes] [--template URL] [--user URL] [--target DIR]

Defaults:
  TEMPLATE: https://github.com/Tecnativa/doodba-copier-template.git
  USER: git@github.com:ramoncunha15/src-odoo.git
  TARGET: current working dir (expected /opt/odoo/crm/develop/odoo/custom/src)

This script will backup and replace: repos.yaml, addons.yaml, .gitignore, scripts/, private/
EOF
}

DRY_RUN=1
TEMPLATE_REPO="https://github.com/Tecnativa/doodba-copier-template.git"
USER_REPO="git@github.com:ramoncunha15/src-odoo.git"
TARGET_DIR="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) DRY_RUN=0; shift ;;
    --template) TEMPLATE_REPO="$2"; shift 2 ;;
    --user) USER_REPO="$2"; shift 2 ;;
    --target) TARGET_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

echo "Template repo: $TEMPLATE_REPO"
echo "User repo:     $USER_REPO"
echo "Target dir:    $TARGET_DIR"
echo "Dry run:       ${DRY_RUN:-1} (use --yes to apply)"

TMPROOT=$(mktemp -d)
TEMPLATE_DIR="$TMPROOT/template"
USER_DIR="$TMPROOT/user"
BACKUP_DIR="$TARGET_DIR/backup_sync_$(date +%Y%m%d%H%M%S)"

echo "Creating temp dir $TMPROOT"

echo "Cloning template repo (shallow)..."
git clone --depth 1 "$TEMPLATE_REPO" "$TEMPLATE_DIR"

echo "Cloning user repo (shallow)..."
git clone --depth 1 "$USER_REPO" "$USER_DIR"

# Files/dirs to replace
REPLACE_ITEMS=("repos.yaml" "addons.yaml" ".gitignore" "scripts" "private")

echo "Will backup originals from $TARGET_DIR to $BACKUP_DIR and copy items from user repo into target."

if [ "$DRY_RUN" -ne 0 ]; then
  echo "DRY RUN — no changes will be applied. Run with --yes to perform."
fi

mkdir -p "$BACKUP_DIR"

for item in "${REPLACE_ITEMS[@]}"; do
  SRC="$USER_DIR/$item"
  DEST="$TARGET_DIR/$item"
  if [ -e "$DEST" ]; then
    echo "Backing up $DEST -> $BACKUP_DIR/"
    if [ "$DRY_RUN" -eq 0 ]; then
      mv "$DEST" "$BACKUP_DIR/"
    fi
  else
    echo "No existing $DEST to backup (ok)."
  fi

  if [ -e "$SRC" ]; then
    echo "Copying $SRC -> $DEST"
    if [ "$DRY_RUN" -eq 0 ]; then
      # Use rsync to copy files/dirs preserving attributes
      mkdir -p "$(dirname "$DEST")"
      rsync -a --delete "$SRC" "$DEST"
    fi
  else
    echo "Warning: $SRC does not exist in user repo; skipping."
  fi
done

echo "All operations simulated."
if [ "$DRY_RUN" -eq 0 ]; then
  echo "Changes applied. Creating a branch and committing changes."
  pushd "$TARGET_DIR" >/dev/null
  BRANCH="sync/template-$(date +%Y%m%d%H%M)"
  git checkout -b "$BRANCH" || git switch -c "$BRANCH"
  git add -A
  git commit -m "chore(sync): apply private modules and config from user repo"
  echo "Pushing branch $BRANCH to origin..."
  git push -u origin "$BRANCH"
  popd >/dev/null
  echo "Commit and push done."
fi

echo "Temporary files remain in $TMPROOT (remove when no longer needed)."

exit 0
