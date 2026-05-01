#!/usr/bin/env bash
set -uo pipefail

# stark-kit — Entorno de Desarrollo con IA, Instalador
# Uso:
#   git clone https://github.com/thestark77/stark-kit.git && cd stark-kit && bash install.sh [TARGET_DIR] [--optional] [--yes]
#
# TARGET_DIR por defecto: directorio actual de trabajo del usuario (o nombre provisto)
# --optional: Instala skills opcionales (vercel-react-best-practices, shadcn)
# --yes/-y:  No pedir confirmación (modo automático, para scripts que llaman a stark-kit)

_starkkit_install() {

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
INSTALL_OPTIONAL=false
AUTO_YES=false
TARGET_DIR=""
for arg in "$@"; do
  case "$arg" in
    --optional) INSTALL_OPTIONAL=true ;;
    --yes|-y) AUTO_YES=true ;;
    *) TARGET_DIR="$arg" ;;
  esac
done
TARGET_DIR="${TARGET_DIR:-$(pwd)}"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}  ${BOLD}stark-kit${NC} — Entorno de Desarrollo con IA          ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  autoSDD + skills + plugins, listo en un comando    ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_step() { echo -e "\n${BLUE}[$1/$TOTAL_STEPS]${NC} ${BOLD}$2${NC}"; }
print_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
print_error(){ echo -e "  ${RED}✗${NC} $1"; }
print_info() { echo -e "  ${CYAN}→${NC} $1"; }

TOTAL_STEPS=6
WARNINGS=()

print_header

# ═══════════════════════════════════════════
# PASO 0: Verificar requisitos
# ═══════════════════════════════════════════
print_step 0 "Verificando requisitos..."

if ! command -v git &>/dev/null; then
  print_error "git no encontrado. Instálalo primero: https://git-scm.com/downloads"
  return 1
fi
print_ok "git instalado"

HAS_CLAUDE=false
if command -v claude &>/dev/null; then
  HAS_CLAUDE=true
  print_ok "Claude Code CLI instalado"
else
  print_warn "Claude Code CLI no encontrado."
  print_warn "Se instalarán archivos de configuración, pero skills y plugins se omitirán."
  print_warn "Instálalo con: npm install -g @anthropic-ai/claude-code"
  echo ""
fi

if command -v pnpm &>/dev/null; then
  PKG_MGR="pnpm"
elif command -v npm &>/dev/null; then
  PKG_MGR="npm"
else
  print_error "npm o pnpm requerido. Instalá Node.js: https://nodejs.org"
  return 1
fi
if [ "$INSTALL_OPTIONAL" = true ]; then
  print_info "Se instalarán skills opcionales (--optional)"
fi

# ═══════════════════════════════════════════
# PASO 1: Validación del directorio de destino
# ═══════════════════════════════════════════
print_step 1 "Preparando directorio de destino: ${TARGET_DIR}"

UPDATE_MODE=false

if [ -d "$TARGET_DIR" ]; then
  file_count=$(find "$TARGET_DIR" -maxdepth 1 -not -name '.' -not -name '..' -not -name '.git' | wc -l)

  if [ "$file_count" -gt 0 ]; then
    echo ""
    print_warn "El directorio ya contiene archivos."
    print_warn "Se actualizarán los archivos de configuración (CLAUDE.md, context/, .claude/)."
    print_warn "NO se tocarán carpetas de código existentes."
    echo ""

    if [[ "$AUTO_YES" == "true" ]] || [[ -r /dev/tty ]]; then
      if [[ "$AUTO_YES" != "true" ]]; then
        read -rp "  ¿Continuar con la actualización? [y/N]: " confirm </dev/tty || confirm=""
      fi
    else
      confirm="y"
    fi

    if [[ "$AUTO_YES" != "true" ]] && [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "  Instalación cancelada."
      return 0
    fi

    UPDATE_MODE=true
  fi
fi

mkdir -p "$TARGET_DIR"
print_ok "Directorio listo: $TARGET_DIR"

# ═══════════════════════════════════════════
# PASO 2: Copiar archivos de configuración
# ═══════════════════════════════════════════
print_step 2 "Copiando archivos de configuración..."

# Crear estructura de directorios
mkdir -p "$TARGET_DIR/context/appVersions"
mkdir -p "$TARGET_DIR/.claude"

# Copiar archivos raíz
for f in CLAUDE.md AGENTS.md .gitignore; do
  if [ -f "$SCRIPT_DIR/templates/$f" ]; then
    cp "$SCRIPT_DIR/templates/$f" "$TARGET_DIR/$f"
    print_ok "$f copiado"
  fi
done

# PROGRESS.md: only copy if it doesn't exist or is still the template default (5 lines or less)
if [ ! -f "$TARGET_DIR/PROGRESS.md" ] || [ "$(wc -l < "$TARGET_DIR/PROGRESS.md" 2>/dev/null)" -le 5 ]; then
  if [ -f "$SCRIPT_DIR/templates/PROGRESS.md" ]; then
    cp "$SCRIPT_DIR/templates/PROGRESS.md" "$TARGET_DIR/PROGRESS.md"
    print_ok "PROGRESS.md copiado"
  fi
else
  print_info "PROGRESS.md ya tiene contenido real — no se sobrescribe"
fi

# Copiar .claude/settings.json (hooks del proyecto)
if [ -f "$SCRIPT_DIR/templates/.claude/settings.json" ]; then
  cp "$SCRIPT_DIR/templates/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
  print_ok ".claude/settings.json (hooks) configurado"
fi

# Copy opencode.json and opencode.md (OpenCode CLI config)
for f in opencode.json opencode.md; do
  if [ -f "$SCRIPT_DIR/templates/$f" ]; then
    cp "$SCRIPT_DIR/templates/$f" "$TARGET_DIR/$f"
    print_ok "$f copiado (OpenCode compatible)"
  fi
done

# ── Detect available AI agents ──────────────────────────────────
echo ""
print_step "" "Detectando agente de IA..."
HAS_CLAUDE=false
HAS_OPENCODE=false

if command -v claude &>/dev/null; then
  HAS_CLAUDE=true
  print_ok "Claude Code CLI detectado"
else
  print_info "Claude Code CLI no encontrado"
fi

if command -v opencode &>/dev/null; then
  HAS_OPENCODE=true
  print_ok "OpenCode CLI detectado"
else
  print_info "OpenCode CLI no encontrado (instalar desde opencode.ai)"
fi

if $HAS_CLAUDE && $HAS_OPENCODE; then
  print_ok "Ambos agentes detectados — configuraciones instaladas para ambos (sin conflictos)"
elif $HAS_CLAUDE; then
  print_ok "Usando Claude Code CLI — hooks en .claude/settings.json activos"
elif $HAS_OPENCODE; then
  print_ok "Usando OpenCode — instrucciones en opencode.md activas (no necesita hooks)"
else
  print_warn "Ningún agente de IA detectado. Instalá Claude Code CLI u OpenCode."
  print_info "  Claude Code: npm install -g @anthropic-ai/claude-code"
  print_info "  OpenCode:    ver https://opencode.ai"
fi

# Copiar archivos de contexto
for f in guidelines.md business_logic.md user_context.md; do
  if [ -f "$SCRIPT_DIR/templates/context/$f" ]; then
    cp "$SCRIPT_DIR/templates/context/$f" "$TARGET_DIR/context/$f"
    print_ok "context/$f copiado"
  fi
done

# ═══════════════════════════════════════════
# PASO 3: Crear estructura base del proyecto
# ═══════════════════════════════════════════
print_step 3 "Creando estructura base del proyecto..."

# Crear directorios típicos de un proyecto (vacíos, para que el dev los llene)
mkdir -p "$TARGET_DIR/src"
mkdir -p "$TARGET_DIR/tests"

print_ok "src/ creado"
print_ok "tests/ creado"
print_info "Estructura base creada. Adaptala a las necesidades de tu proyecto."

# ═══════════════════════════════════════════
# PASO 4: Instalar autoSDD
# ═══════════════════════════════════════════
print_step 4 "Instalando autoSDD v6.1..."
print_info "Esto abrirá el instalador interactivo de autoSDD."
print_info "Seleccioná los agentes que uses (al menos claude-code)."
echo ""

if [[ -r /dev/tty ]]; then
  bash <(curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh) </dev/tty
  autosdd_status=$?
else
  curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash
  autosdd_status=$?
fi

if [ $autosdd_status -eq 0 ]; then
  print_ok "autoSDD instalado exitosamente"
else
  print_warn "autoSDD pudo haber tenido errores. Verificá la instalación."
  WARNINGS+=("Verificá que autoSDD se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
fi

# ═══════════════════════════════════════════
# PASO 5: Instalar skills y plugins adicionales
# ═══════════════════════════════════════════
print_step 5 "Instalando skills y plugins adicionales..."

if [ "$HAS_CLAUDE" = true ]; then

# Core skills (always installed)
CORE_SKILLS=(
  "gentleman-programming/sdd-agent-team"
  "davidcastagnetoa/skills"
)

for skill_repo in "${CORE_SKILLS[@]}"; do
  skill_name=$(basename "$skill_repo")
  echo -e "  ${CYAN}→${NC} Instalando skill: $skill_name..."
  if claude skill install "github:$skill_repo" 2>/dev/null; then
    print_ok "$skill_name instalado"
  else
    print_info "$skill_name ya instalado o no disponible"
  fi
done

# Optional skills (only with --optional)
if [ "$INSTALL_OPTIONAL" = true ]; then
  OPTIONAL_SKILLS=(
    "vercel-labs/agent-skills"
    "shadcn-ui/ui"
  )

  echo ""
  print_info "Instalando skills opcionales (--optional)..."
  for skill_repo in "${OPTIONAL_SKILLS[@]}"; do
    skill_name=$(basename "$skill_repo")
    echo -e "  ${CYAN}→${NC} Instalando skill: $skill_name..."
    if claude skill install "github:$skill_repo" 2>/dev/null; then
      print_ok "$skill_name instalado (opcional)"
    else
      print_info "$skill_name ya instalado o no disponible"
    fi
  done
fi

# Plugins
echo ""
print_info "Instalando plugins de Claude Code..."

PLUGINS=(
  "engram@engram"
  "frontend-design@claude-plugins-official"
  "code-review@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
)

for plugin in "${PLUGINS[@]}"; do
  plugin_name=$(echo "$plugin" | cut -d'@' -f1)
  echo -e "  ${CYAN}→${NC} Plugin: $plugin_name..."
  if claude plugin install "$plugin" 2>/dev/null; then
    print_ok "$plugin_name instalado"
  else
    print_info "$plugin_name ya instalado o no disponible"
  fi
done

# claude-powerline: conditional (only if Claude Code is present)
echo -e "  ${CYAN}→${NC} Plugin: claude-powerline..."
if claude plugin install "claude-powerline@claude-powerline" 2>/dev/null; then
  print_ok "claude-powerline instalado"
else
  print_info "claude-powerline ya instalado o no disponible"
fi

else
  print_warn "Claude Code CLI no encontrado. Saltando skills y plugins."
  print_info "Instala Claude Code y ejecuta este instalador de nuevo para obtener skills y plugins."
  echo ""
  echo -e "  ${YELLOW}Skills omitidas:${NC} sdd-agent-team, davidcastagnetoa/skills"
  if [ "$INSTALL_OPTIONAL" = true ]; then
    echo -e "  ${YELLOW}Skills opcionales omitidas:${NC} vercel-labs/agent-skills, shadcn-ui/ui"
  fi
  echo -e "  ${YELLOW}Plugins omitidos:${NC} engram, frontend-design, code-review, code-simplifier, claude-powerline"
fi

# ═══════════════════════════════════════════
# PASO 6: Inicializar repositorio git
# ═══════════════════════════════════════════
print_step 6 "Finalizando configuración..."

cd "$TARGET_DIR" || return 1

if [ ! -d ".git" ]; then
  git init -q
  git add CLAUDE.md AGENTS.md .gitignore PROGRESS.md context/ .claude/settings.json opencode.json opencode.md 2>/dev/null
  git commit -q -m "init: stark-kit setup"
  print_ok "Repositorio git inicializado"
else
  print_info "Repositorio git ya existe"
fi

# Crear carpeta de primera versión
mkdir -p "context/appVersions/v0.1.0"

# ═══════════════════════════════════════════
# RESUMEN
# ═══════════════════════════════════════════
echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ¡Instalación completada!${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Directorio:${NC} $TARGET_DIR"
echo ""

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo ""
  echo -e "  ${YELLOW}Advertencias:${NC}"
  for w in "${WARNINGS[@]}"; do
    echo -e "    ${YELLOW}⚠${NC} $w"
  done
fi

echo ""
echo -e "  ${BOLD}Próximos pasos:${NC}"
echo -e "    1. Personalizá context/guidelines.md con el stack de tu proyecto"
echo -e "    2. Completá context/user_context.md con tu perfil"
echo -e "    3. Completá context/business_logic.md con la lógica de negocio de tu proyecto"
echo -e "    4. Adaptá CLAUDE.md y AGENTS.md a tu proyecto"
echo -e "    5. Abrí tu agente de IA:"
echo -e "       Claude Code: cd $TARGET_DIR && claude"
echo -e "       OpenCode:    cd $TARGET_DIR && opencode"
echo -e "    6. Probá con: '¿qué skills tengo disponibles?'"
echo ""
echo -e "  ${BOLD}Lee el README.md para el tutorial completo.${NC}"
if [ "$INSTALL_OPTIONAL" = false ]; then
  echo ""
  echo -e "  ${CYAN}Tip:${NC} Para instalar skills opcionales (vercel-react-best-practices, shadcn),"
  echo -e "        ejecutá: bash install.sh --optional"
fi
echo ""

}

_starkkit_install "$@"
