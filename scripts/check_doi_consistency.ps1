#!/usr/bin/env pwsh
<#
.SYNOPSIS
  After every Zenodo paper mint: fail if a superseded record ID still appears
  outside ZENODO.md's history / allowlisted paths.

.DESCRIPTION
  Zenodo mints 10.5281/zenodo.<record_id> per version. The paper body should
  cite the concept DOI (stable). Version IDs live in ZENODO.md and CITATION.cff.
  This guard stops the "released paper cites a dead record" failure mode.

  Add the previous current version ID to SupersededIds when a new version is minted.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

# Prior paper version record IDs that must not appear as live citation targets
# outside allowlisted files. Concept ID 21705468 is never superseded.
$SupersededIds = @(
    "21705469",  # first paper mint
    "21705738",  # v1.0.1 pre-errata
    "21706741",  # errata upload; PDF self-DOI still lagged
    "21710366"   # pre-published-ARIA-constants PDF
)

# Paths (repo-relative, forward slashes) where superseded IDs may still appear.
$Allowlist = @(
    "ZENODO.md",
    "CHANGELOG.md",
    "scripts/check_doi_consistency.ps1",
    "SEARCH-META.html"
)

$CurrentVersionId = "21710821"
$ConceptId = "21705468"

Set-Location $RepoRoot

$fail = $false
$hits = @()

$files = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch '[\\/]\.git[\\/]' -and
        $_.Extension -match '\.(md|cff|html|json|py|txt|yml|yaml|ps1)$'
    }

foreach ($id in $SupersededIds) {
    foreach ($f in $files) {
        $rel = ($f.FullName.Substring($RepoRoot.Length).TrimStart('\', '/') -replace '\\', '/')
        if ($Allowlist -contains $rel) { continue }
        # catalog slug in README is documented stale until site re-point — allow with warning
        $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { continue }
        if ($content -notmatch [regex]::Escape($id)) { continue }
        # Catalog path fragment -21705469 is historical URL only (not a live DOI).
        if ($id -eq "21705469" -and ($rel -match 'README\.md|ZENODO\.md|SEARCH-META\.html|CHANGELOG\.md')) {
            continue
        }
        $hits += [pscustomobject]@{ Id = $id; Path = $rel }
        $fail = $true
    }
}

# Current version + concept should appear in the citation surfaces
$needCurrent = @("CITATION.cff", "ZENODO.md", "SEARCH-META.html")
foreach ($rel in $needCurrent) {
    $p = Join-Path $RepoRoot $rel
    if (-not (Test-Path $p)) {
        Write-Error "Missing $rel"
        $fail = $true
        continue
    }
    $c = Get-Content -LiteralPath $p -Raw
    if ($c -notmatch [regex]::Escape($CurrentVersionId)) {
        Write-Error "$rel does not mention current paper version id $CurrentVersionId"
        $fail = $true
    }
}

# Paper body should cite concept, not a bare superseded version as sole DOI
foreach ($paper in @("ARIA-Moebius-v1-REL.md", "PAPER_ARIA_MOBIUS_DRAFT_v3.md")) {
    $p = Join-Path $RepoRoot $paper
    if (-not (Test-Path $p)) { continue }
    $c = Get-Content -LiteralPath $p -Raw
    if ($c -notmatch [regex]::Escape($ConceptId)) {
        Write-Error "$paper missing concept DOI $ConceptId"
        $fail = $true
    }
    foreach ($id in $SupersededIds) {
        if ($c -match [regex]::Escape($id)) {
            Write-Error "$paper still contains superseded id $id"
            $fail = $true
        }
    }
}

if ($hits.Count) {
    Write-Host "Superseded DOI hits outside allowlist:" -ForegroundColor Red
    $hits | Format-Table -AutoSize | Out-String | Write-Host
}

if ($fail) {
    Write-Host "FAIL: fix DOI consistency before release." -ForegroundColor Red
    exit 1
}

Write-Host "OK: no superseded paper DOIs outside allowlist; concept + current version present." -ForegroundColor Green
exit 0
