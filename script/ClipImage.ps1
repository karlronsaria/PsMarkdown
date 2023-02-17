function Save-ClipboardToImageFormat {
    # Needed for `-ErrorAction SilentyContinue`
    [CmdletBinding()]
    Param(
        [String]
        $BasePath = (Get-Location).Path,

        [String]
        $FolderName = "res",

        [String]
        $FileName = (Get-Date -Format "yyyy_MM_dd_HHmmss"),

        [String]
        $FileExtension = ".png"
    )

    $obj = [PsCustomObject]@{
        Success = $false
        Path = ""
        MarkdownString = ""
    }

    $format = 'None'
    $clip = Get-Clipboard -Format Image

    if ($clip -eq $null) {
        $clip = Get-Clipboard -Format FileDropList
    } else {
        $format = 'Image'
    }

    if ($clip -eq $null) {
        Write-Error "No image found on Clipboard."
        return $obj
    } else {
        $format = 'FileDropList'
    }

    $BasePath = Join-Path $BasePath $FolderName

    if (-not (Test-Path $BasePath)) {
        New-Item -Path $BasePath -ItemType Directory | Out-Null

        if (-not (Test-Path $BasePath)) {
            Write-Error "Failed to find/create subdirectory '$FolderName'."
            return $obj
        }
    }

    $item_name = ""

    switch ($format) {
        'Image' {
            $base_name = "$FileName$FileExtension"
            $item_name = Join-Path $BasePath $base_name
            $clip.Save($item_name)
            $link_name = $FileName
        }

        'FileDropList' {
            $item = $clip[0]
            $base_name = $item.Name
            $item_name = Join-Path $BasePath $base_name
            [void] $item.CopyTo($item_name, $true)
            $link_name = $base_name
        }
    }

    if (-not (Test-Path $item_name)) {
        Write-Error "Failed to save image to '$item_name'."
        return $obj
    }

    # 2021_11_25: This new line necessary for rendering with typora-0.11.18
    $item_path = Join-Path "." $FolderName
    $item_path = Join-Path $item_path $base_name

    return [PsCustomObject]@{
        Success = $true
        Path = $item_name
        MarkdownString = "![$link_name]($($item_path.Replace('\', '/')))"
    }
}

function Move-ToTrashFolder {
    Param(
        [String]
        $Path,

        [String]
        $TrashFolder = '__OLD'
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

