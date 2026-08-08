<#
.SYNOPSIS
    Dumps every format currently on the Windows clipboard to individual files.

.DESCRIPTION
    See ../specs/Export-Clipboard-Spec.md for the authoritative behavioral
    contract. This script is one implementation of that contract.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class ClipboardOwnerInfo {
    [DllImport("user32.dll")]
    public static extern IntPtr GetClipboardOwner();

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
}
"@

# Known clipboard format names -> file extension.
# These are the official registered format names (RegisterClipboardFormat),
# not something PowerShell/.NET is inventing or reinterpreting.
$extensionMap = @{
    'Text'                    = '.txt'   # CF_TEXT (predefined)
    'UnicodeText'             = '.txt'   # CF_UNICODETEXT (predefined)
    'HTML Format'             = '.html'  # informally "CF_HTML" - registered name is literally "HTML Format"
    'Rich Text Format'        = '.rtf'   # informally "CF_RTF"
    'Csv'                     = '.csv'
    'FileDrop'                = '.txt'   # CF_HDROP - list of file paths, not binary
    'UniformResourceLocator'  = '.txt'   # source URL, ANSI-encoded
    'UniformResourceLocatorW' = '.txt'   # source URL, Unicode-encoded
    'PNG'                     = '.png'   # already raw PNG bytes, no conversion needed
}

# A few formats need a non-default text encoding when decoded from a raw stream.
$encodingMap = @{
    'UniformResourceLocatorW' = [System.Text.Encoding]::Unicode
}

# Timestamped output folder, in the same directory as this script
$baseDir = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
$stamp   = Get-Date -Format "yyyyMMdd_HHmmss"
$outDir  = Join-Path $baseDir "clipboard_dump_$stamp"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
Write-Host "Output directory: $outDir"

# --- Identify the source app (best-effort) ---
$ownerHwnd = [ClipboardOwnerInfo]::GetClipboardOwner()
$sourceInfo = if ($ownerHwnd -ne [IntPtr]::Zero) {
    $procId = 0
    [ClipboardOwnerInfo]::GetWindowThreadProcessId($ownerHwnd, [ref]$procId) | Out-Null
    try {
        $proc = Get-Process -Id $procId -ErrorAction Stop
        $path = try { $proc.Path } catch { "(access denied)" }
        "Owner HWND: $ownerHwnd`nProcess: $($proc.ProcessName) (PID $procId)`nPath: $path"
    } catch {
        "Owner HWND: $ownerHwnd`nProcess ID: $procId (process exited or inaccessible)"
    }
} else {
    "No clipboard owner window found."
}
$sourceInfo | Out-File (Join-Path $outDir "clipboardSource.txt") -Encoding utf8
Write-Host $sourceInfo

# --- Dump every format on the clipboard ---
$data = [System.Windows.Forms.Clipboard]::GetDataObject()

if ($null -eq $data -or $data.GetFormats().Count -eq 0) {
    Write-Host "Clipboard is empty."
    return
}

foreach ($fmt in $data.GetFormats()) {
    $safeName = $fmt -replace '[\\/:*?"<>|]', '_'

    try {
        $val = $data.GetData($fmt)
    } catch {
        Write-Host "$fmt -> failed to retrieve ($($_.Exception.Message))"
        continue
    }

    if ($null -eq $val) {
        Write-Host "$fmt -> no data returned"
        continue
    }

    $ext = $extensionMap[$fmt]

    if ($val -is [System.Drawing.Image]) {
        if (-not $ext) { $ext = '.png' }
        $val.Save((Join-Path $outDir "clip_$safeName$ext"), [System.Drawing.Imaging.ImageFormat]::Png)
    }
    elseif ($val -is [System.IO.Stream]) {
        if (-not $ext) { $ext = '.bin' }
        $bytes = New-Object byte[] $val.Length
        $val.Read($bytes, 0, $val.Length) | Out-Null
        $val.Dispose()

        if ($ext -in '.txt', '.html', '.rtf', '.csv') {
            # Text-bearing format delivered as raw bytes - decode instead of dumping binary
            $enc = $encodingMap[$fmt]
            if (-not $enc) { $enc = [System.Text.Encoding]::UTF8 }
            $text = $enc.GetString($bytes).TrimEnd([char]0)
            [System.IO.File]::WriteAllText((Join-Path $outDir "clip_$safeName$ext"), $text, [System.Text.Encoding]::UTF8)
        } else {
            [System.IO.File]::WriteAllBytes((Join-Path $outDir "clip_$safeName$ext"), $bytes)
        }
    }
    else {
        if (-not $ext) { $ext = '.txt' }
        $val | Out-File (Join-Path $outDir "clip_$safeName$ext") -Encoding utf8
    }

    Write-Host "$fmt -> $($val.GetType().FullName)  ($ext)"
}

Write-Host "`nDumped to: $outDir"
