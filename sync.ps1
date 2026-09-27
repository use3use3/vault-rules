#Requires -Version 5.1
<#
  vault-rules 同期スクリプト

  D:\Vault の中から「公開してよいルール類」だけを D:\vault-rules へコピーし、
  GitHub の public リポジトリ use3use3/vault-rules へ push する。

  スマホの Claude / ChatGPT は、この public リポジトリの raw URL を読んで
  ローカルと同じルールで動く。

  使い方: このファイルを右クリック →「PowerShell で実行」
          または PowerShell で  D:\vault-rules\sync.ps1
#>

$ErrorActionPreference = 'Stop'

$VaultRoot  = 'D:\Vault'
$PublicRoot = 'D:\vault-rules'

# ---- 公開するファイル（Vaultルートからの相対パス） -------------------------
# ここに無いものは公開されない。追加したいファイルはこの配列に足す。
$Files = @(
    'CLAUDE.md'
    'MISTAKES.md'
    '10_Specialists\camera\CLAUDE.md'
    '10_Specialists\camera\MEMORY.md'
    '10_Specialists\camera\MISTAKES.md'
    '10_Specialists\korean\CLAUDE.md'
    '10_Specialists\korean\MEMORY.md'
    '10_Specialists\korean\MISTAKES.md'
    '10_Specialists\dev\CLAUDE.md'
    '10_Specialists\dev\MISTAKES.md'
)

# ---------------------------------------------------------------------------

Write-Host "=== vault-rules 同期 ===" -ForegroundColor Cyan

if (-not (Test-Path $VaultRoot))  { throw "Vault が見つかりません: $VaultRoot" }
if (-not (Test-Path $PublicRoot)) { throw "公開フォルダが見つかりません: $PublicRoot" }

# 1. 古い公開ファイルを削除（Vault側で消したものを残さないため）
#    .git / README.md / sync.ps1 / test.md は消さない
Get-ChildItem $PublicRoot -Force |
    Where-Object { $_.Name -notin @('.git', 'README.md', 'sync.ps1', 'test.md') } |
    Remove-Item -Recurse -Force

# 2. コピー
$copied  = 0
$missing = @()

foreach ($rel in $Files) {
    $src = Join-Path $VaultRoot  $rel
    $dst = Join-Path $PublicRoot $rel

    if (-not (Test-Path $src)) {
        $missing += $rel
        continue
    }

    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }

    Copy-Item $src $dst -Force
    $copied++
    Write-Host "  コピー: $rel"
}

Write-Host ""
Write-Host "$copied 件をコピーしました。" -ForegroundColor Green

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "見つからなかったファイル（$($missing.Count)件）:" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    Write-Host "Vault 側で移動・改名された可能性があります。sync.ps1 の `$Files を確認してください。" -ForegroundColor Yellow
}

# 3. 差分がなければ終了
Push-Location $PublicRoot
try {
    $status = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($status)) {
        Write-Host ""
        Write-Host "変更はありません。push 不要です。" -ForegroundColor Green
        return
    }

    Write-Host ""
    Write-Host "=== 変更内容 ===" -ForegroundColor Cyan
    git status --short

    # 4. commit & push
    Write-Host ""
    git add -A
    git commit -m "Sync rules from Vault ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
    git push

    Write-Host ""
    Write-Host "公開完了しました。" -ForegroundColor Green
}
finally {
    Pop-Location
}
