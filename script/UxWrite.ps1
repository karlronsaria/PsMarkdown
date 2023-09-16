function Get-UxItem {
    Param(
        [ArgumentCompleter({
            $setting = cat "$PsScriptRoot/../res/setting.json" `
                | ConvertFrom-Json

            $size = $setting.DefaultImageSize
            $ext = $setting.DefaultExtension

            return dir "$PsScriptRoot/../res/$ext/$size" `
                -File `
                | foreach {
                    [Regex]::Match($_, ".*(?=\.[^\.]+$)")
                }
        })]
        [String]
        $Name,

        [Int]
        $Size = -1,

        [String]
        $Extension,

        [Switch]
        $UseExactMatch
    )

    $setting = cat "$PsScriptRoot/../res/setting.json" `
        | ConvertFrom-Json

    if ($Size -lt 0) {
        $Size = $setting.DefaultImageSize
    }

    if ([String]::IsNullOrWhiteSpace($Extension)) {
        $Extension = $setting.DefaultExtension
    }

    return dir "$PsScriptRoot/../res/$Extension/$Size" `
        -File `
        | where {
            $_.Name -like "$Name$(if (-not $UseExactMatch) { "**" })"
        } `
        | foreach {
            [PsCustomObject]@{
                FullName = $_.FullName
                MarkdownString =
                    "![$($_.Name)](./$($setting.ResourceDir)/$($_.Name))"
            }
        }
}

function ConvertTo-MdUxWriteDoc {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [System.IO.FileInfo]
        $File,

        [String]
        $Delimiter,

        [Switch]
        $UseExactMatch,

        [Switch]
        $Force
    )

    $setting = cat "PsScriptRoot/../res/setting.json" `
        | ConvertFrom-Json

    if ([String]::IsNullOrWhiteSpace($Delimiter)) {
        $Delimiter = $setting.Delimiter
    }

    $pattern = "(?<=$Delimiter)[^$Delimiter]+(?=$Delimiter)"

    $basePath = New-ResourceDirectory `
        -BasePath $File.Directory `
        -FolderName $setting.ResourceDir

    $cat = foreach ($line in (cat $File)) {
        $capture = [Regex]::Match($line, $pattern)

        while ($capture.Success) {
            $value = $capture.Value

            $items = Get-UxItem `
                -Name $value `
                -UseExactMatch:$UseExactMatch

            foreach ($item in $items) {
                $name = Split-Path $item.FullName -Leaf

                Copy-Item `
                    -Path $item.FullName `
                    -Destination (Join-Path $basePath $name)
            }

            $replace = @($items | foreach { $_.MarkdownString }) -Join ' '

            $line = $line -replace `
                "$Delimiter$value$Delimiter", `
                $replace

            $capture = [Regex]::Match($line, $pattern)
        }

        Write-Output $line
    }

    $baseName = Replace-DateTimeStamp `
        -InputObject $File.BaseName `
        -Format $setting.DateTimeFormat `
        -Pattern $setting.DateTimePattern

    $next = $File.FullName
    $prev = "$baseName$($File.Extension)"
    Rename-Item $next $prev -Force:$Force
    $cat | Out-File $next -Force:$Force
}
