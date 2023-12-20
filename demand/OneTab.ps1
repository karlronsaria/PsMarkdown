<#
Tags: OneTab ot markdown md link url convert
#>
function Convert-OneTabToMarkdown {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [String[]]
        $InputObject
    )

    Process {
        $InputObject |
        foreach {
            [PsCustomObject]@{
                Capture =
                    [Regex]::Match(
                        $_,
                        "^(?<url>https://[^\|]+)\s*\|\s*(?<title>.+)$"
                    )
                Line = $_
            }
        } |
        foreach {
            if ($_.Capture.Success) {
                $groups = $_.Capture.Groups
                $url = $groups['url'].Value.Trim()
                $title = $groups['title'].Value.Trim()

                "- [$title]($url)"
            }
            else {
                $_.Line
            }
        }
    }
}
