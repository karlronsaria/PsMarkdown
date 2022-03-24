function Save-ClipboardToImageFormat {
    # Needed for `-ErrorAction SilentyContinue`
    [CmdletBinding()]
    Param(
        [String]
        $BasePath = (Get-Location),

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

    $clip = Get-Clipboard -Format Image

    if ($clip -eq $null) {
        Write-Error "No image found on Clipboard."
        return $obj
    }

    $BasePath = Join-Path $BasePath $FolderName

    if (-not (Test-Path $BasePath)) {
        New-Item -Path $BasePath -ItemType Directory | Out-Null

        if (-not (Test-Path $BasePath)) {
            Write-Error "Failed to find/create subdirectory '$FolderName'."
            return $obj
        }
    }

    $item_name = Join-Path $BasePath "$FileName$FileExtension"
    $clip.Save($item_name)

    if (-not (Test-Path $item_name)) {
        Write-Error "Failed to save image to '$item_name'."
        return $obj
    }

    # 2021_11_25: This new line necessary for rendering with typora-0.11.18
    $item_path = Join-Path "." $FolderName
    $item_path = Join-Path $item_path "$FileName$FileExtension"

    return [PsCustomObject]@{
        Success = $true
        Path = $item_name
        MarkdownString = "![$FileName](/$($item_path.Replace('\', '/')))"
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

