function Get-MarkdownLink {
    Param(
        [Object[]]
        $Directory
    )

    function Get-CaptureGroup {
        Param(
            [Object[]]
            $MatchInfo,

            [String]
            $GroupName
        )

        foreach ($item in $MatchInfo) {
            $path = $item.Path

            foreach ($capture in $item.Matches) {
                $value = $capture.Groups[$GroupName].Value

                if ([String]::IsNullOrWhiteSpace($value)) {
                    continue
                }

                $type = ''

                switch -Regex ($value) {
                    '^\.\.?(\\|\/)' {
                        $type = 'Relative'
                        $parent = Split-Path $path -Parent
                        $path = Join-Path $parent $value
                    }

                    default {
                        $type = 'Absolute'
                    }
                }

                $found = Test-Path $path

                [PsCustomObject]@{
                    Capture = $value
                    Type = $type
                    Found = $found
                    Path = $path
                }
            }
        }
    }

    $webPattern = "https?://[^\s`"]+"
    $linkPattern = "\[[^\[\]]*\]\s*\()[^\(\)]+(?=\))"
    $referencePattern = "(?<=$linkPattern"
    $imagePattern = "(?<=!$linkPattern"

    $what = $Directory `
        | sls "(?<web>$webPattern)|(?<image>$imagePattern)|(?<reference>$referencePattern)"

    return [PsCustomObject]@{
        Web = Get-CaptureGroup $what -GroupName 'web'
        Reference = Get-CaptureGroup $what -GroupName 'reference'
        Image = Get-CaptureGroup $what -GroupName 'image'
    }
}
