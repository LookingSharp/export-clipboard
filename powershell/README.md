# Export-Clipboard (PowerShell)

This is the PowerShell implementation of Export-Clipboard, one implementation
of the behavioral contract defined in
[`../specs/Export-Clipboard-Spec.md`](../specs/Export-Clipboard-Spec.md).

## Usage

Run the script directly:

```powershell
.\Export-Clipboard.ps1
```

It creates a `clipboard_dump_<yyyyMMdd_HHmmss>` folder alongside the script,
containing one file per clipboard format currently available, plus
`clipboardSource.txt` describing the application that last wrote to the
clipboard (best-effort).

## Requirements

Windows PowerShell 5.1 or PowerShell 7+, run on Windows.
