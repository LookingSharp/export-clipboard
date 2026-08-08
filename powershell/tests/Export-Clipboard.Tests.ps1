Describe 'Export-Clipboard.ps1' {
    It 'is syntactically valid PowerShell' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'Export-Clipboard.ps1'
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$null, [ref]$errors) | Out-Null
        $errors.Count | Should -Be 0
    }
}
