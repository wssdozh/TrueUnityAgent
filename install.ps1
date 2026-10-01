<#
.SYNOPSIS
    Установщик универсальных правил true-unity-agent в целевой Unity-проект.

.DESCRIPTION
    Копирует модульные правила (.agents/rules/), точки входа (CLAUDE.md, AGENTS.md, .cursorrules)
    в указанный каталог Unity-проекта с сохранением локальных файлов при необходимости.

.PARAMETER TargetPath
    Путь к корню целевого Unity-проекта (по умолчанию: текущая директория).

.EXAMPLE
    .\install.ps1 -TargetPath "C:\Users\morii\Projects\MyNewGame"
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [string]$TargetPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   true-unity-agent installer" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

$SourceDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($SourceDir)) {
    $SourceDir = (Get-Location).Path
}

$TemplatesDir = Join-Path $SourceDir "templates"
if (-not (Test-Path $TemplatesDir)) {
    Write-Error "Не найдена папка шаблонов: $TemplatesDir"
    exit 1
}

Write-Host "Целевой проект: $TargetPath" -ForegroundColor Green

# 1. Проверяем, что это корень репозитория / Unity проекта
$AssetsPath = Join-Path $TargetPath "Assets"
if (-not (Test-Path $AssetsPath)) {
    Write-Warning "Внимание: В целевой папке нет директории 'Assets'. Убедитесь, что запускаете установщик в корне Unity проекта."
}

# 2. Создаем директории .agents/rules в проекте
$DestAgentsDir = Join-Path $TargetPath ".agents"
$DestRulesDir = Join-Path $DestAgentsDir "rules"

New-Item -ItemType Directory -Path $DestRulesDir -Force | Out-Null
Write-Host "✓ Создана структура папок .agents/rules/" -ForegroundColor Green

# 3. Копируем модульные правила
$SourceRules = Join-Path $TemplatesDir ".agents\rules"
Get-ChildItem -Path $SourceRules -Filter "*.md" | ForEach-Object {
    $destFile = Join-Path $DestRulesDir $_.Name
    Copy-Item -Path $_.FullName -Destination $destFile -Force
    Write-Host "  → Скопировано правило: $($_.Name)" -ForegroundColor Gray
}

# Копируем .agents/README.md
$sourceAgentsReadme = Join-Path $TemplatesDir ".agents\README.md"
if (Test-Path $sourceAgentsReadme) {
    Copy-Item -Path $sourceAgentsReadme -Destination (Join-Path $DestAgentsDir "README.md") -Force
}

# 4. Копируем точки входа: CLAUDE.md, AGENTS.md, .cursorrules
$entryFiles = @("CLAUDE.md", "AGENTS.md", ".cursorrules")
foreach ($file in $entryFiles) {
    $src = Join-Path $TemplatesDir $file
    $dest = Join-Path $TargetPath $file
    if (Test-Path $src) {
        if (Test-Path $dest) {
            Write-Warning "Файл $file уже существует в целевом проекте. Создана резервная копия $file.bak"
            Copy-Item -Path $dest -Destination "$dest.bak" -Force
        }
        Copy-Item -Path $src -Destination $dest -Force
        Write-Host "✓ Установлен $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Готово. Правила и шаблоны true-unity-agent скопированы в $TargetPath" -ForegroundColor Green
