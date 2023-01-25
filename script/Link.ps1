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

        function Get-CaptureGroup {
            Param(
                [Object[]]
                $MatchInfo,

                [String]
                $GroupName,

                [Switch]
                $Web
            )

            foreach ($item in $MatchInfo) {
                $linkPath = $item.Path

                foreach ($capture in $item.Matches) {
                    $value = $capture.Groups[$GroupName].Value

                    if ([String]::IsNullOrWhiteSpace($value)) {
                        continue
                    }

                    $type = ''

                    switch -Regex ($value) {
                        '^\.\.?(\\|\/)' {
                            $type = 'Relative'
                            $parent = Split-Path $linkPath -Parent
                            $linkPath = Join-Path $parent $value
                        }

                        default {
                            $type = 'Absolute'
                            $linkPath = $value
                        }
                    }

                    $found = if ($Web) {
                        Test-WebRequest -Uri $linkPath
                    } else {
                        Test-Path $linkPath
                    }

                    [PsCustomObject]@{
                        Capture = $value
                        Type = $type
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
            "(?<web>$webPattern)|(?<image>$imagePattern)|(?<reference>$referencePattern)"
        $list = @()
    }

    Process {
        $what = $Directory `
            | sls $searchPattern

        if ($null -eq $what) {
            return
        }

        $web = Get-CaptureGroup $what -GroupName 'web' -Web:$TestWebLink

        foreach ($item in $web) {
            $item.Type = 'Web'
        }

        $list += @([PsCustomObject]@{
            Web = $web
            Reference = Get-CaptureGroup $what -GroupName 'reference'
            Image = Get-CaptureGroup $what -GroupName 'image'
        })
    }

    End {
        return [PsCustomObject]@{
            Web = $list.Web
            Reference = $list.Reference
            Image = $list.Image
        }
    }
}

