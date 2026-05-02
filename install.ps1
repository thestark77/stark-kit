#Requires -Version 5.1

# stark-kit — Entorno de Desarrollo con IA, Instalador (PowerShell)
# Uso:
#   git clone https://github.com/thestark77/stark-kit.git; cd stark-kit; .\install.ps1 [TARGET_DIR] [-Optional] [-Yes] [-SkillsOnly]
#
# TARGET_DIR por defecto: directorio actual de trabajo
# -Optional:    Instala skills opcionales (vercel-react-best-practices, shadcn)
# -Yes:         No pedir confirmación (modo automático, para scripts que llaman a stark-kit)
# -SkillsOnly:  Solo actualiza autoSDD, skills y plugins sin tocar archivos del proyecto

param(
  [string]$TargetDir,
  [switch]$Optional,
  [switch]$Yes,
  [switch]$SkillsOnly
)

$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

if (-not $TargetDir) {
  $TargetDir = Get-Location
}

# ── Helpers ──────────────────────────────────────────

function Print-Header {
  Write-Host ""
  Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
  Write-Host "  ║  " -ForegroundColor Cyan -NoNewline
  Write-Host "stark-kit" -NoNewline -ForegroundColor White
  Write-Host " — Entorno de Desarrollo con IA     " -NoNewline
  Write-Host "║" -ForegroundColor Cyan
  Write-Host "  ║  autoSDD + skills + plugins, listo en un comando  ║" -ForegroundColor Cyan
  Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
  Write-Host ""
}

function Print-Step {
  param([int]$Num, [string]$Msg)
  Write-Host ""
  Write-Host "[$Num/$TotalSteps] " -ForegroundColor Blue -NoNewline
  Write-Host $Msg -ForegroundColor White
}

function Print-Ok {
  param([string]$Msg)
  Write-Host "  ✓ " -ForegroundColor Green -NoNewline
  Write-Host $Msg
}

function Print-Warn {
  param([string]$Msg)
  Write-Host "  ⚠ " -ForegroundColor Yellow -NoNewline
  Write-Host $Msg
}

function Print-Error {
  param([string]$Msg)
  Write-Host "  ✗ " -ForegroundColor Red -NoNewline
  Write-Host $Msg
}

function Print-Info {
  param([string]$Msg)
  Write-Host "  → " -ForegroundColor Cyan -NoNewline
  Write-Host $Msg
}

$TotalSteps = 6
$Warnings = [System.Collections.Generic.List[string]]::new()
$AutoYes = $Yes.IsPresent

Print-Header

# ═══════════════════════════════════════════
# STEP 0: Prerequisites check
# ═══════════════════════════════════════════
Print-Step 0 "Verificando requisitos..."

# Check git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Print-Error "git no encontrado. Instálalo primero: https://git-scm.com/downloads"
  exit 1
}
Print-Ok "git instalado"

# Check claude CLI
$HasClaude = $false
if (Get-Command claude -ErrorAction SilentlyContinue) {
  $HasClaude = $true
  Print-Ok "Claude Code CLI instalado"
} else {
  Print-Warn "Claude Code CLI no encontrado."
  Print-Warn "Se instalarán archivos de configuración, pero skills y plugins se omitirán."
  Print-Warn "Instálalo con: npm install -g @anthropic-ai/claude-code"
  Write-Host ""
}

# Check npm/pnpm
$PkgMgr = $null
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
  $PkgMgr = "pnpm"
} elseif (Get-Command npm -ErrorAction SilentlyContinue) {
  $PkgMgr = "npm"
} else {
  Print-Error "npm o pnpm requerido. Instala Node.js: https://nodejs.org"
  exit 1
}
Print-Ok "$PkgMgr disponible"

if ($InstallOptional) {
  Print-Info "Se instalarán skills opcionales (-Optional)"
}

# ═══════════════════════════════════════════
# STEP 1: Directory validation + install mode
# ═══════════════════════════════════════════
Print-Step 1 "Preparando directorio de destino: $TargetDir"

$UpdateMode = $false
$SkillsOnlyMode = $false

# Resolve SkillsOnly mode from flag
if ($SkillsOnly.IsPresent) {
  $SkillsOnlyMode = $true
}

# Detect existing installation (CLAUDE.md is the marker)
$existingClaudeMd = Join-Path $TargetDir "CLAUDE.md"
$HasExistingInstall = (Test-Path $TargetDir) -and (Test-Path $existingClaudeMd)

if ($HasExistingInstall) {
  $UpdateMode = $true

  if (-not $AutoYes -and -not $SkillsOnlyMode) {
    # Show interactive menu
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │  " -ForegroundColor Cyan -NoNewline
    Write-Host "Instalación existente detectada." -NoNewline -ForegroundColor White
    Write-Host "               │" -ForegroundColor Cyan
    Write-Host "  │                                                 │" -ForegroundColor Cyan
    Write-Host "  │  " -ForegroundColor Cyan -NoNewline
    Write-Host "[1]" -NoNewline -ForegroundColor White
    Write-Host " Instalación completa" -NoNewline
    Write-Host "                       │" -ForegroundColor Cyan
    Write-Host "  │      Sobreescribe archivos de configuración     │" -ForegroundColor Cyan
    Write-Host "  │      (CLAUDE.md, context/, .claude/, etc.)      │" -ForegroundColor Cyan
    Write-Host "  │                                                 │" -ForegroundColor Cyan
    Write-Host "  │  " -ForegroundColor Cyan -NoNewline
    Write-Host "[2]" -NoNewline -ForegroundColor White
    Write-Host " Solo skills y plugins" -NoNewline
    Write-Host "                      │" -ForegroundColor Cyan
    Write-Host "  │      Actualiza autoSDD, skills y plugins        │" -ForegroundColor Cyan
    Write-Host "  │      sin tocar archivos del proyecto            │" -ForegroundColor Cyan
    Write-Host "  └─────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""

    $choice = Read-Host "  Seleccioná (1/2)"

    switch ($choice) {
      "1" { <# full install, default #> }
      "2" { $SkillsOnlyMode = $true }
      ""  { <# empty = default = full install #> }
      default {
        Write-Host "  Instalación cancelada." -ForegroundColor Yellow
        exit 0
      }
    }
  }
  # If -Yes is set, defaults to full install (SkillsOnlyMode stays $false unless -SkillsOnly was set)
}

if (-not (Test-Path $TargetDir)) {
  New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

if ($SkillsOnlyMode) {
  Print-Ok "Directorio listo: $TargetDir (modo skills-only)"
} else {
  Print-Ok "Directorio listo: $TargetDir"
}

# ═══════════════════════════════════════════
# STEP 2: Copy template files
# ═══════════════════════════════════════════
Print-Step 2 "Copiando archivos de configuración..."

if ($SkillsOnlyMode) {
  Print-Info "Modo skills-only — archivos de configuración no modificados"
} else {

# Create directory structure
$contextVersionsDir = Join-Path $TargetDir "context/appVersions"
$claudeDir = Join-Path $TargetDir ".claude"
New-Item -ItemType Directory -Path $contextVersionsDir -Force | Out-Null
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null

# Copy CLAUDE.md, AGENTS.md, .gitignore
foreach ($f in @("CLAUDE.md", "AGENTS.md", ".gitignore")) {
  $src = Join-Path $ScriptDir "templates/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $TargetDir $f) -Force
    Print-Ok "$f copiado"
  }
}

# PROGRESS.md: only copy if it doesn't exist or is still the template default (5 lines or less)
$progressPath = Join-Path $TargetDir "PROGRESS.md"
$progressSrc = Join-Path $ScriptDir "templates/PROGRESS.md"
if (-not (Test-Path $progressPath)) {
  if (Test-Path $progressSrc) {
    Copy-Item -Path $progressSrc -Destination $progressPath -Force
    Print-Ok "PROGRESS.md copiado"
  }
} else {
  $progressLines = (Get-Content $progressPath -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
  if ($progressLines -le 5) {
    if (Test-Path $progressSrc) {
      Copy-Item -Path $progressSrc -Destination $progressPath -Force
      Print-Ok "PROGRESS.md copiado"
    }
  } else {
    Print-Info "PROGRESS.md ya tiene contenido real — no se sobrescribe"
  }
}

# Copy .claude/settings.json (project hooks)
$settingsSrc = Join-Path $ScriptDir "templates/.claude/settings.json"
if (Test-Path $settingsSrc) {
  Copy-Item -Path $settingsSrc -Destination (Join-Path $claudeDir "settings.json") -Force
  Print-Ok ".claude/settings.json (hooks) configurado"
}

# Copy opencode.json and opencode.md (OpenCode CLI config)
foreach ($f in @("opencode.json", "opencode.md")) {
  $src = Join-Path $ScriptDir "templates/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $TargetDir $f) -Force
    Print-Ok "$f copiado (OpenCode compatible)"
  }
}

# ── Detect available AI agents ──────────────────────────────────
Write-Host ""
Print-Step "" "Detectando agente de IA..."
$HasClaude = $false
$HasOpenCode = $false

if (Get-Command claude -ErrorAction SilentlyContinue) {
  $HasClaude = $true
  Print-Ok "Claude Code CLI detectado"
} else {
  Print-Info "Claude Code CLI no encontrado"
}

if (Get-Command opencode -ErrorAction SilentlyContinue) {
  $HasOpenCode = $true
  Print-Ok "OpenCode CLI detectado"
} else {
  Print-Info "OpenCode CLI no encontrado (instalar desde opencode.ai)"
}

if ($HasClaude -and $HasOpenCode) {
  Print-Ok "Ambos agentes detectados — configuraciones instaladas para ambos (sin conflictos)"
} elseif ($HasClaude) {
  Print-Ok "Usando Claude Code CLI — hooks en .claude/settings.json activos"
} elseif ($HasOpenCode) {
  Print-Ok "Usando OpenCode — instrucciones en opencode.md activas (no necesita hooks)"
} else {
  Print-Warn "Ningún agente de IA detectado. Instalá Claude Code CLI u OpenCode."
  Print-Info "  Claude Code: npm install -g @anthropic-ai/claude-code"
  Print-Info "  OpenCode:    ver https://opencode.ai"
}

# Copy context files
$contextDir = Join-Path $TargetDir "context"
foreach ($f in @("guidelines.md", "business_logic.md", "user_context.md")) {
  $src = Join-Path $ScriptDir "templates/context/$f"
  if (Test-Path $src) {
    Copy-Item -Path $src -Destination (Join-Path $contextDir $f) -Force
    Print-Ok "context/$f copiado"
  }
}

} # end if (-not $SkillsOnlyMode)

# ═══════════════════════════════════════════
# STEP 3: Create base project structure
# ═══════════════════════════════════════════
Print-Step 3 "Creando estructura base del proyecto..."

if ($SkillsOnlyMode) {
  Print-Info "Modo skills-only — estructura del proyecto no modificada"
} else {

New-Item -ItemType Directory -Path (Join-Path $TargetDir "src") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TargetDir "tests") -Force | Out-Null

Print-Ok "src/ creado"
Print-Ok "tests/ creado"
Print-Info "Estructura base creada. Adaptala a las necesidades de tu proyecto."

} # end if (-not $SkillsOnlyMode)

# ═══════════════════════════════════════════
# STEP 4: Install autoSDD
# ═══════════════════════════════════════════
Print-Step 4 "Instalando autoSDD v6.1..."
Print-Info "Esto abrirá el instalador interactivo de autoSDD."
Print-Info "Selecciona los agentes que uses (al menos claude-code)."
Write-Host ""

try {
  Invoke-RestMethod https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | Invoke-Expression
  Print-Ok "autoSDD instalado exitosamente"
} catch {
  # Fallback: try bash installer via Git Bash if available
  $gitBash = Get-Command bash -ErrorAction SilentlyContinue
  if ($gitBash) {
    Print-Info "Intentando instalador bash como fallback..."
    bash -c 'curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash'
    if ($LASTEXITCODE -eq 0) {
      Print-Ok "autoSDD instalado via bash"
    } else {
      Print-Warn "autoSDD pudo haber tenido errores. Verifica la instalación."
      $Warnings.Add("Verifica que autoSDD se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
    }
  } else {
    Print-Warn "autoSDD pudo haber tenido errores. Verifica la instalación."
    $Warnings.Add("Verifica que autoSDD se instaló correctamente: ~/.claude/skills/autosdd/SKILL.md")
  }
}

# ═══════════════════════════════════════════
# STEP 5: Install additional skills & plugins
# ═══════════════════════════════════════════
Print-Step 5 "Instalando skills y plugins adicionales..."

if ($HasClaude) {

# Core skills (always installed)
$CoreSkills = @(
  "gentleman-programming/sdd-agent-team"
  "davidcastagnetoa/skills"
)

foreach ($skillRepo in $CoreSkills) {
  $skillName = Split-Path -Leaf $skillRepo
  Print-Info "Instalando skill: $skillName..."
  $result = claude skill install "github:$skillRepo" 2>&1
  if ($LASTEXITCODE -eq 0) {
    Print-Ok "$skillName instalado"
  } else {
    Print-Info "$skillName ya instalado o no disponible"
  }
}

# Optional skills (only with -Optional)
if ($InstallOptional) {
  $OptionalSkills = @(
    "vercel-labs/agent-skills"
    "shadcn-ui/ui"
  )

  Write-Host ""
  Print-Info "Instalando skills opcionales (-Optional)..."
  foreach ($skillRepo in $OptionalSkills) {
    $skillName = Split-Path -Leaf $skillRepo
    Print-Info "Instalando skill: $skillName..."
    $result = claude skill install "github:$skillRepo" 2>&1
    if ($LASTEXITCODE -eq 0) {
      Print-Ok "$skillName instalado (opcional)"
    } else {
      Print-Info "$skillName ya instalado o no disponible"
    }
  }
}

# Plugins
Write-Host ""
Print-Info "Instalando plugins de Claude Code..."

$Plugins = @(
  @{ Name = "engram";           Id = "engram@engram" }
  @{ Name = "frontend-design";  Id = "frontend-design@claude-plugins-official" }
  @{ Name = "code-review";      Id = "code-review@claude-plugins-official" }
  @{ Name = "code-simplifier";  Id = "code-simplifier@claude-plugins-official" }
)

foreach ($plugin in $Plugins) {
  Print-Info "Plugin: $($plugin.Name)..."
  $result = claude plugin install $plugin.Id 2>&1
  if ($LASTEXITCODE -eq 0) {
    Print-Ok "$($plugin.Name) instalado"
  } else {
    Print-Info "$($plugin.Name) ya instalado o no disponible"
  }
}

# claude-powerline: conditional (only if Claude Code is present)
Print-Info "Plugin: claude-powerline..."
$result = claude plugin install "claude-powerline@claude-powerline" 2>&1
if ($LASTEXITCODE -eq 0) {
  Print-Ok "claude-powerline instalado"
} else {
  Print-Info "claude-powerline ya instalado o no disponible"
}

} else {
  Print-Warn "Claude Code CLI no encontrado. Saltando skills y plugins."
  Print-Info "Instala Claude Code y ejecuta este instalador de nuevo para obtener skills y plugins."
  Write-Host ""
  Write-Host "  Skills omitidas: sdd-agent-team, davidcastagnetoa/skills" -ForegroundColor Yellow
  if ($InstallOptional) {
    Write-Host "  Skills opcionales omitidas: vercel-labs/agent-skills, shadcn-ui/ui" -ForegroundColor Yellow
  }
  Write-Host "  Plugins omitidos: engram, frontend-design, code-review, code-simplifier, claude-powerline" -ForegroundColor Yellow
}

# ═══════════════════════════════════════════
# STEP 6: Initialize git repo at root
# ═══════════════════════════════════════════
Print-Step 6 "Finalizando configuración..."

Push-Location $TargetDir

if (-not $SkillsOnlyMode) {
  # Init root git repo if not exists
  if (-not (Test-Path ".git")) {
    git init -q
    git add CLAUDE.md AGENTS.md .gitignore PROGRESS.md context/ .claude/settings.json opencode.json opencode.md 2>$null
    git commit -q -m "init: stark-kit setup"
    Print-Ok "Repositorio raíz inicializado"
  } else {
    Print-Info "Repositorio raíz ya existe"
  }

  # Create appVersions/v0.1.0
  $v010Dir = Join-Path $TargetDir "context/appVersions/v0.1.0"
  New-Item -ItemType Directory -Path $v010Dir -Force | Out-Null
} else {
  Print-Info "Modo skills-only — repositorio git no modificado"
}

Pop-Location

# ═══════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════
Write-Host ""
Write-Host "  ══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "    ¡Instalación completada!" -ForegroundColor Green
Write-Host "  ══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Directorio: " -NoNewline -ForegroundColor White
Write-Host $TargetDir
if ($SkillsOnlyMode) {
  Write-Host "  Modo: " -NoNewline -ForegroundColor White
  Write-Host "Solo skills y plugins (archivos de proyecto no modificados)"
}
Write-Host ""

if ($Warnings.Count -gt 0) {
  Write-Host ""
  Write-Host "  Advertencias:" -ForegroundColor Yellow
  foreach ($w in $Warnings) {
    Write-Host "    ⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $w
  }
}

Write-Host ""
Write-Host "  Próximos pasos:" -ForegroundColor White
Write-Host "    1. Personalizá context/guidelines.md con el stack de tu proyecto"
Write-Host "    2. Completá context/user_context.md con tu perfil"
Write-Host "    3. Completá context/business_logic.md con la lógica de negocio de tu proyecto"
Write-Host "    4. Adaptá CLAUDE.md y AGENTS.md a tu proyecto"
Write-Host "    5. Abrí tu agente de IA:"
Write-Host "       Claude Code: cd $TargetDir && claude"
Write-Host "       OpenCode:    cd $TargetDir && opencode"
Write-Host "    6. Probá con: '¿qué skills tengo disponibles?'"
Write-Host ""
Write-Host "  Lee el README.md para el tutorial completo." -ForegroundColor White
if (-not $InstallOptional) {
  Write-Host ""
  Write-Host "  Tip: Para instalar skills opcionales (vercel-react-best-practices, shadcn)," -ForegroundColor Cyan
  Write-Host "       ejecutá: .\install.ps1 -Optional" -ForegroundColor Cyan
}
Write-Host ""
