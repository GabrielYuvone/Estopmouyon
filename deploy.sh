#!/usr/bin/env bash
# ============================================================
# ESTOPMOUYON — Deploy a GitHub Pages
# ============================================================
# Este script sube todos los archivos de la PWA al repositorio
# https://github.com/GabrielYuvone/Estopmouyon
#
# CÓMO USARLO:
# 1. Descargá la carpeta pwa/ completa (con el .git adentro)
# 2. Abrí una terminal en esa carpeta
# 3. Ejecutá: bash deploy.sh
#
# El script te va a pedir tu usuario de GitHub y un Personal Access Token.
# Si no tenés un token, crealo en:
#   https://github.com/settings/tokens/new?scopes=repo
# (marcá solo el scope "repo", generás el token, lo copiás)
# ============================================================

set -e

REPO_URL="https://github.com/GabrielYuvone/Estopmouyon.git"
BRANCH="main"

echo "============================================================"
echo "  ESTOPMOUYON — Deploy a GitHub Pages"
echo "============================================================"
echo ""
echo "Subiendo archivos al repositorio:"
echo "  $REPO_URL"
echo ""

# Verificar que estamos en la carpeta correcta
if [ ! -f "index.html" ] || [ ! -f "manifest.json" ] || [ ! -f "sw.js" ]; then
  echo "✗ Error: no estás en la carpeta pwa/ correcta."
  echo "  Necesitás ver: index.html, manifest.json, sw.js en esta carpeta."
  exit 1
fi

# Verificar que git está disponible
if ! command -v git >/dev/null 2>&1; then
  echo "✗ Error: git no está instalado."
  echo "  Instalalo desde: https://git-scm.com/downloads"
  exit 1
fi

echo "→ Archivos a subir:"
git ls-files | head -20
echo ""

# Hacer commit si hay cambios
if ! git diff --quiet HEAD 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "→ Detectados cambios. Creando commit..."
  git add .
  git commit -m "Update ESTOPMOUYON PWA" 2>&1 | tail -3
else
  echo "→ Sin cambios nuevos. Pusheando commit existente..."
fi

echo ""
echo "→ Subiendo a GitHub..."
echo "  Si te pide usuario: tu usuario de GitHub"
echo "  Si te pide password: pegá tu Personal Access Token"
echo "  (no tu contraseña de GitHub — un token de:"
echo "   https://github.com/settings/tokens)"
echo ""

git push -u "$REPO_URL" "$BRANCH" 2>&1 || {
  echo ""
  echo "✗ El push falló. Posibles causas:"
  echo "  1) No tenés permisos para pushear a GabrielYuvone/Estopmouyon"
  echo "     — pedile al dueño del repo que te agregue como colaborador"
  echo "     — o forkeá el repo y cambiá REPO_URL arriba"
  echo "  2) El token no tiene scope 'repo'"
  echo "  3) Estás usando contraseña en vez de token (GitHub ya no lo permite)"
  exit 1
}

echo ""
echo "============================================================"
echo "  ✓ LISTO — Archivos subidos a GitHub"
echo "============================================================"
echo ""
echo "Próximos pasos:"
echo ""
echo "1. Activá GitHub Pages:"
echo "   Andá a: https://github.com/GabrielYuvone/Estopmouyon/settings/pages"
echo "   Source: Deploy from a branch"
echo "   Branch: main  /root  → Save"
echo ""
echo "2. Esperá 1-2 minutos. Tu app estará en:"
echo "   https://gabrielyuvone.github.io/Estopmouyon/"
echo ""
echo "3. Para instalarla en el celu:"
echo "   Android: abrí ese link en Chrome → 'Instalar ESTOPMOUYON'"
echo "   iPhone:  abrí ese link en Safari → Compartir → Agregar a pantalla inicio"
echo ""
