function Get-MdCodeBlock {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String[]]
        $InputObject,

        [String]
        $Language
    )

    Begin {
        $snippets = @()
        $snippet = $null
    }

    Process {
        foreach ($line in $InputObject) {
            if ($null -eq $snippet) {
                $blockStart = [Regex]::Match(
                    $line,
                    "^(?<indent>\s*)``````(?<lang>\S+)?"
                )

                $lang = $blockStart.Groups['lang'].Value

                if (-not [String]::IsNullOrWhiteSpace($Language) `
                    -and $lang.ToLower() -ne $Language.ToLower()
                ) {
                    continue
                }

                if ($blockStart.Success) {
                    $snippet = [PsCustomObject]@{
                        Lines = @()
                        Language = $lang
                        Indent = $blockStart.Groups['indent'].Value
                    }
                }
            }
            else {
                $blockEnd = [Regex]::Match(
                    $line,
                    "^\s*``````"
                )

                if ($blockEnd.Success) {
                    $snippets += @($snippet)
                    $snippet = $null
                }
                else {
                    Write-Host "Line: $line"
                    $snippet.Lines += @(
                        $line -replace "^$($snippet.Indent)", ""
                    )
                }
            }
        }
    }

    End {
        return $snippets | foreach {
            [PsCustomObject]@{
                Lines = $_.Lines
                Language = $_.Language
            }
        }
    }
}
