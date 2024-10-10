<#
.DESCRIPTION
Tags: markdown cancel worklist item strikethrough strikethru
#>
function ConvertTo-MarkdownCanceledItem {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String[]]
        $InputString
    )

    Begin {
        $patterns = @(
            "(?<=^\s*(-|\d+\.) \[( |x)\]\s+)(?=\S)",
            "(?<=^\s*(-|\d+\.)\s+)(?=\S)",
            "(?<=^\s*)(?=\S)"
        )
    }

    Process {
        foreach ($subitem in $InputString) {
            foreach ($pattern in $patterns) {
                $capture = [Regex]::Match($subitem, $pattern)

                if ($capture.Success) {
                    $subitem = $subitem.Insert($capture.Index, '~~')
                    break
                }
            }

            $subitem = $subitem -replace "(?<=^\s*(-|\d+\.) \[) (?=\]\s+)", 'x'
            $subitem -replace "(?<=\S)(?=\s*$)", '~~'
        }
    }
}

