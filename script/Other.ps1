function New-ResourceDirectory {
    # Needed for ``-ErrorAction SilentyContinue``
    [CmdletBinding()]
    Param(
        [String]
        $BasePath = (Get-Location).Path,

        [String]
        $FolderName,

        [Switch]
        $WhatIf
    )

    if ([String]::IsNullOrWhiteSpace($FolderName)) {
        $setting = Get-Item "$PsScriptRoot/../res/setting.json" |
            Get-Content |
            ConvertFrom-Json

        $FolderName = $setting.ResourceDir
    }

    $BasePath = Join-Path $BasePath $FolderName

    if (-not (Test-Path $BasePath)) {
        $null = New-Item `
            -Path $BasePath `
            -ItemType Directory `
            -WhatIf:$WhatIf

        if (-not $WhatIf -and -not (Test-Path $BasePath)) {
            Write-Error "Failed to find/create subdirectory '$FolderName'"
            return
        }
    }

    return $BasePath
}

