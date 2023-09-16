function Get-ClipboardFormat {
    # Needed for ``-ErrorAction SilentyContinue``
    [CmdletBinding()]
    Param()

    $format = 'Text'
    $success = $false
    $clip = Get-Clipboard -Format Image

    if ($null -eq $clip) {
        $clip = Get-Clipboard -Format FileDropList
    } else {
        $success = $true
        $format = 'Image'
    }

    if ($format -eq 'Text') {
        if ($null -eq $clip) {
            $clip = Get-Clipboard -Format Text
        } else {
            $success = $true
            $format = 'FileDropList'
        }
    }

    if ($format -eq 'Text') {
        if ($null -eq $clip) {
            Write-Error 'No image found on Clipboard'
        }
        else {
            $success = $true
            $format = 'Text'
        }
    }

    return [PsCustomObject]@{
        Success = $success
        Format = $format
        Clip = $clip
    }
}

function New-MarkdownLink {
    # Needed for ``-ErrorAction SilentyContinue``
    [CmdletBinding()]
    Param(
        [String]
        $FolderName,

        [String]
        $BaseName,

        [String]
        $ItemName,

        [String]
        $LinkName,

        [String]
        $Format,

        [PsCustomObject]
        $ErrorObject,

        [Switch]
        $WhatIf
    )

    if (-not $WhatIf -and -not (Test-Path $ItemName)) {
        Write-Error "Failed to save image to '$ItemName'"
        return $ErrorObject
    }

    # 2021_11_25: This new line necessary for rendering with
    # typora-0.11.18
    $item_path = Join-Path "." $FolderName
    $item_path = Join-Path $item_path $BaseName

    return [PsCustomObject]@{
        Success = $true
        Path = $ItemName
        MarkdownString = "![$LinkName]($($item_path.Replace('\', '/')))"
        Format = $Format
    }
}

function Save-ClipboardToImageFormat {
    # Needed for ``-ErrorAction SilentyContinue``
    [CmdletBinding()]
    Param(
        [String]
        $BasePath = (Get-Location).Path,

        [String]
        $FolderName = "res",

        [String]
        $FileName = (Get-Date -Format "yyyy_MM_dd_HHmmss"),

        [String]
        $FileExtension = ".png",

        [Switch]
        $Force,

        [Switch]
        $WhatIf,

        [ArgumentCompleter({
            [System.IO.FileInfo].DeclaredProperties.Name
        })]
        [ValidateScript({
            $_ -in [System.IO.FileInfo].DeclaredProperties.Name
        })]
        [String]
        $OrderFileDropListBy = 'Name'
    )

    $format = 'Text'

    $obj = [PsCustomObject]@{
        Success = $false
        Path = ""
        MarkdownString = ""
        Format = $format
    }

    $result = Get-ClipboardFormat
    $obj.Success = $result.Success
    $obj.Format = $result.Format

    if (-not $result.Success) {
        return $obj
    }

    $clip = $result.Clip

    $BasePath = New-ResourceDirectory `
        -BasePath $BasePath `
        -FolderName $FolderName `
        -WhatIf:$WhatIf

    if ($null -eq $BasePath) {
        return $obj
    }

    $item_name = ""

    switch ($format) {
        "FileDropList" {
            $objects = @()

            foreach ($item in $clip | sort -Property $OrderFileDropListBy) {
                $base_name = $item.Name
                $item_name = Join-Path $BasePath $base_name
                $link_name = $base_name

                if (-not $WhatIf) {
                    [void] $item.CopyTo($item_name, $Force)
                }

                $objects += @(New-MarkdownLink `
                    -FolderName $FolderName `
                    -BaseName $base_name `
                    -ItemName $item_name `
                    -LinkName $link_name `
                    -Format $format `
                    -ErrorObject $obj `
                    -WhatIf:$WhatIf
                )
            }

            return $objects
        }

        "Image" {
            $base_name = @("$FileName$FileExtension")
            $item_name = Join-Path $BasePath $base_name
            $link_name = $FileName

            if (-not $WhatIf) {
                $clip.Save($item_name)
            }
        }

        "Text" {
            if (-not (Test-Path $clip)) {
                Write-Error "No file found at $clip"
                return $obj
            }

            $base_name = Split-Path $item.Name -Leaf
            $item_name = Join-Path $BasePath $base_name
            $link_name = $base_name

            if (-not $WhatIf) {
                Copy-Item $clip $item_name -Force:$Force
            }
        }
    }

    return New-MarkdownLink `
        -FolderName $FolderName `
        -BaseName $base_name `
        -ItemName $item_name `
        -LinkName $link_name `
        -Format $format `
        -ErrorObject $obj `
        -WhatIf:$WhatIf
}

function Move-ToTrashFolder {
    Param(
        [String]
        $Path,

        [String]
        $TrashFolder = "__OLD"
    )

    $Path = Join-Path (Get-Location) $Path
    $parent = Split-Path $Path -Parent
    $leaf = Split-Path $Path -Leaf
    $trash = Join-Path $parent $TrashFolder

    if ((Test-Path $Path)) {
        if (-not (Test-Path $trash)) {
            mkdir $trash -Force | Out-Null
        }

        Move-Item $Path $trash -Force | Out-Null
    }

    Get-Item (Join-Path $trash $leaf)
}

