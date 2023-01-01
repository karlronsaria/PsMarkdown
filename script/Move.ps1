function Move-MarkdownItem {
    Param(
        [String]
        $Source,

        [String]
        $Destination,

        [Switch]
        $Force
    )

    function Get-MarkdownLocalResource {
        Param(
            [Alias('Path')]
            [String]
            $ItemPath
        )

        $pattern = "!\[[^\[\]]+\]\((?<Resource>[^\(\)]+)\)"
        $dir = (Get-Item $ItemPath).Directory

        foreach ($line in (cat $ItemPath)) {
            $capture = [Regex]::Match($line, $pattern)

            if ($capture.Success) {
                $value = $capture.Groups['Resource'].Value
                $resourcePath = Join-Path $dir $value
                $exists = Test-Path $resourcePath

                [PsCustomObject]@{
                    String = $value
                    Path = $resourcePath
                    Exists = $exists
                    FileInfo = if ($exists) {
                        Get-Item $resourcePath
                    } else {
                        $null
                    }
                }
            }
        }
    }

    $dir = (Get-Item $Source).Directory

    $resource = Get-MarkdownLocalResource `
        -ItemPath $Source

    foreach ($subitem in $resource) {
        $resourceDest = Join-Path $Destination $subitem.String
        $parentPath = Split-Path $subitem.String
        $resourceParentDest = Join-Path $Destination $parentPath

        if (-not (Test-Path $resourceParentDest)) {
            New-Item `
                -Path $resourceParentDest `
                -ItemType Directory `
                -Force:$Force
        }

        Move-Item `
            -Path $subitem.Path `
            -Destination $resourceDest `
            -Force:$Force
    }

    Move-Item `
        -Path $Source `
        -Destination $Destination `
        -Force:$Force
}
