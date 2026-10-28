#requires -Version 7.0

$ErrorActionPreference = 'Stop'

$repoUrl = if ($args.Count -ge 1) { $args[0] } else { 'git@github.com:tadmccorkle/dotfiles.git' }
$dotfilesDir = Join-Path $env:USERPROFILE '.dotfiles'

function Fail([string] $Message) {
    [Console]::Error.WriteLine("error: $Message")
    exit 1
}

function dotfiles {
    & git "--git-dir=$dotfilesDir" "--work-tree=$env:USERPROFILE" @args
}

Set-Location -LiteralPath $env:USERPROFILE

if (Test-Path -LiteralPath $dotfilesDir) {
    & git "--git-dir=$dotfilesDir" rev-parse --is-bare-repository *> $null
    if ($LASTEXITCODE -ne 0) {
        Fail "'$dotfilesDir' exists but is not a bare git repository"
    }
} else {
    Write-Host "Cloning $repoUrl into '$dotfilesDir'..."
    & git clone -b cfg --bare $repoUrl $dotfilesDir
    if ($LASTEXITCODE -ne 0) {
        Fail "failed to clone $repoUrl"
    }
}

& git "--git-dir=$dotfilesDir" rev-parse --verify --quiet refs/heads/cfg *> $null
if ($LASTEXITCODE -ne 0) {
    & git "--git-dir=$dotfilesDir" rev-parse --verify --quiet refs/remotes/origin/cfg *> $null
    if ($LASTEXITCODE -eq 0) {
        & git "--git-dir=$dotfilesDir" branch cfg origin/cfg
        if ($LASTEXITCODE -ne 0) {
            Fail "failed to create the 'cfg' branch"
        }
    } else {
        Fail "'$dotfilesDir' does not contain a 'cfg' branch"
    }
}

$oldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$checkoutOutput = @(dotfiles checkout 2>&1 | ForEach-Object { $_.ToString() })
$checkoutExit = $LASTEXITCODE
$ErrorActionPreference = $oldErrorActionPreference

if ($checkoutExit -ne 0) {
    $checkoutText = $checkoutOutput -join [Environment]::NewLine
    [Console]::Error.WriteLine($checkoutText)

    if ($checkoutText -notmatch 'would be overwritten by checkout|would be removed by checkout|already exists in working directory') {
        Fail 'failed to check out dotfiles.'
    }

    $match = [regex]::Match(
        $checkoutText,
        '(?s)(?:would be overwritten by checkout|would be removed by checkout):\s*\r?\n(.*?)(?:\r?\n(?:Please|Aborting)|$)'
    )
    if (!$match.Success) {
        Fail 'failed to check out dotfiles.'
    }

    $conflicts = @(
        $match.Groups[1].Value -split "\r?\n" |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ } |
            Sort-Object -Unique
    )
    if ($conflicts.Count -eq 0) {
        Fail 'failed to check out dotfiles.'
    }

    $backupBase = Join-Path $env:USERPROFILE '.dotfiles.bak'
    $backupDir = $backupBase
    $suffix = 0
    while (Test-Path -LiteralPath $backupDir) {
        $suffix++
        $backupDir = "$backupBase.$suffix"
    }

    Write-Host "Backing up pre-existing dotfiles to '$backupDir'..."
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    foreach ($file in $conflicts) {
        $src = Join-Path $env:USERPROFILE $file
        if ($null -eq (Get-Item -LiteralPath $src -Force -ErrorAction SilentlyContinue)) {
            continue
        }

        $dest = Join-Path $backupDir $file
        $parent = Split-Path -Parent $dest
        if ($parent) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        Move-Item -LiteralPath $src -Destination $dest
    }

    dotfiles checkout
    if ($LASTEXITCODE -ne 0) {
        Fail 'failed to check out dotfiles after backing up conflicts.'
    }
}

dotfiles config --local status.showUntrackedFiles no
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine('warning: failed to hide untracked files.')
}

dotfiles config branch.cfg.remote origin
if ($LASTEXITCODE -ne 0) {
    Fail "failed to configure upstream tracking for 'cfg'"
}

dotfiles config branch.cfg.merge refs/heads/cfg
if ($LASTEXITCODE -ne 0) {
    Fail "failed to configure upstream tracking for 'cfg'"
}

Write-Host 'Dotfiles applied.'
Write-Host ''
Write-Host "To use the 'dotfiles' command immediately, define it in your PowerShell session:"
Write-Host ''
Write-Host "  function dotfiles { & git `"--git-dir=`$env:USERPROFILE/.dotfiles`" `"--work-tree=`$env:USERPROFILE`" @args }"
Write-Host ''
Write-Host 'Recommended: reload your PowerShell profile or restart your session.'
