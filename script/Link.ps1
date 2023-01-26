function Get-MarkdownLink {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        $Directory,

        [Switch]
        $TestWebLink
    )

    Begin {
        function Test-WebRequest {
            Param(
                [String]
                $Uri
            )

            $HTTP_Response = $null
            $HTTP_Request = [System.Net.WebRequest]::Create($Uri)
            $HTTP_Response = $HTTP_Request.GetResponse()

            if ($null -eq $HTTP_Response) {
                return $null
            }

            $HTTP_Status = [int]$HTTP_Response.StatusCode
            $HTTP_Response.Close()
            return 200 -eq $HTTP_Status
        }

        function Get-CaptureGroupName {
            Param(
                [Object[]]
                $MatchInfo
            )

            $groups = $MatchInfo.Groups `
                | where {
                    $_.Success `
                    -and $_.Length -gt 0 `
                    -and $_.Name -notmatch "\d+"
                }

            return $groups.Name
        }

        function Get-CaptureGroup {
            Param(
                [Object[]]
                $MatchInfo,

                [Switch]
                $TestWebLink
            )

            foreach ($item in $MatchInfo) {
                $linkPath = $item.Path

                foreach ($capture in $item.Matches) {
                    $groupName = Get-CaptureGroupName $capture
                    $value = $capture.Groups[$groupName].Value

                    if (@($groupName).Count -gt 0) {
                        $groupName = @($groupName)[0]
                    }

                    if ([String]::IsNullOrWhiteSpace($value)) {
                        continue
                    }

                    $searchMethod = ''

                    switch -Regex ($value) {
                        '^\.\.?(\\|\/)' {
                            $searchMethod = 'Relative'
                            $parent = Split-Path $linkPath -Parent
                            $linkPath = Join-Path $parent $value
                        }

                        default {
                            $searchMethod = 'Absolute'
                            $linkPath = $value
                        }
                    }

                    $found = if ($TestWebLink -and $groupName -eq 'Web') {
                        Test-WebRequest -Uri $linkPath
                    } else {
                        Test-Path $linkPath
                    }

                    [PsCustomObject]@{
                        Capture = $value
                        Type = $groupName
                        SearchMethod = $searchMethod
                        Found = $found
                        LinkPath = $linkPath
                        FilePath = $item.Path
                    }
                }
            }
        }

        $webPattern = "https?://[^\s`"]+"
        $linkPattern = "\[[^\[\]]*\]\s*\()[^\(\)]+(?=\))"
        $referencePattern = "(?<=$linkPattern"
        $imagePattern = "(?<=!$linkPattern"
        $searchPattern =
            "(?<Web>$webPattern)|(?<Image>$imagePattern)|(?<Reference>$referencePattern)"
    }

    Process {
        $what = $Directory `
            | sls $searchPattern

        if ($null -eq $what) {
            return
        }

        $items = Get-CaptureGroup $what `
            -TestWebLink:$TestWebLink

        foreach ($item in $items) {
            $item.Type = 'Uri'
        }

        return $items
    }
}

