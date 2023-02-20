function Get-MarkdownLink {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        $Directory,

        [Switch]
        $TestWebLink,

        [Switch]
        $PassThru
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
                $TestWebLink,

                [Switch]
                $PassThru
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

                    $obj = [PsCustomObject]@{
                        Capture = $value
                        Type = $groupName
                        SearchMethod = $searchMethod
                        Found = $found
                        LinkPath = $linkPath
                        FilePath = $item.Path
                    }

                    if ($PassThru) {
                        $obj | Add-Member `
                            -MemberType 'NoteProperty' `
                            -Name 'MatchInfo' `
                            -Value $item
                    }

                    Write-Output $obj
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
        if ($Directory -is [String]) {
            $Directory = Get-ChildItem $Directory
        }

        $what = $Directory `
            | sls $searchPattern

        if ($null -eq $what) {
            return
        }

        $items = Get-CaptureGroup $what `
            -TestWebLink:$TestWebLink `
            -PassThru:$PassThru

        return $items
    }
}

function ConvertTo-MarkdownLinkSearchMethod {
    Param(
        [Parameter(
            ParameterSetName = 'ByCustomObject',
            ValueFromPipeline = $true
        )]
        [PsCustomObject]
        $InputObject,

        [Parameter(
            ParameterSetName = 'ByTwoStrings'
        )]
        [String]
        $OriginPath,

        [Parameter(
            ParameterSetName = 'ByTwoStrings'
        )]
        [String]
        $DestinationPath,

        [ValidateSet('Absolute', 'Relative')]
        [String]
        $SearchMethod = 'Relative'
    )

    Begin {
        function Get-CommonPrefix {
            Param(
                [String]
                $InputString,

                [String]
                $ReferenceString
            )

            $iEnum = $InputString.GetEnumerator()
            $rEnum = $ReferenceString.GetEnumerator()
            $prefix = ''

            while ($iEnum.MoveNext() -and $rEnum.MoveNext()) {
                if ($iEnum.Current -ne $rEnum.Current) {
                    break
                }

                $prefix += $iEnum.Current
            }

            $iTail = $iEnum.Current

            while ($iEnum.MoveNext()) {
                $iTail += $iEnum.Current
            }

            $rTail = if (([String]$iTail).Length -gt 0) {
                $rEnum.Current
            } else {
                ""
            }

            while ($rEnum.MoveNext()) {
                $rTail += $rEnum.Current
            }

            return [PsCustomObject]@{
                Prefix = $prefix
                InputTail = $iTail
                ReferenceTail = $rTail
            }
        }

        function Format-Link {
            Param(
                [String]
                $Link
            )

            $Link = $Link.Trim()
            $Link = $Link.Replace('\', '/')
            $Link = $Link -Replace '^\./\.\./', '../'
            $Link = $Link -Replace '(?<=.+/)\./', ''
            return $Link
        }
    }

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            'ByCustomObject' {
                $OriginPath = $InputObject.FilePath
                $DestinationPath = $InputObject.LinkPath
            }
        }

        $dir = dir $OriginPath -ErrorAction 'SilentlyContinue'

        if ($null -ne $dir -and $dir.Mode -match '^-a') {
            $OriginPath = Split-Path $OriginPath -Parent
        }

        $OriginPath = $OriginPath.Replace('\', '/')
        $DestinationPath = $DestinationPath.Replace('\', '/')

        $what = Get-CommonPrefix `
            -InputString $OriginPath `
            -ReferenceString $DestinationPath

        switch ($SearchMethod) {
            'Relative' {
                $nodes = if ([String]::IsNullOrWhiteSpace($what.InputTail)) {
                    0
                } else {
                    ([String] $what.InputTail).Trim('/').Split('/').Count
                }

                $fullPath = "."
                $node = 1

                while ($node -lt $nodes) {
                    $fullPath = Join-Path $fullPath '..'
                    $node = $node + 1
                }

                $fullPath = Join-Path $fullPath $what.ReferenceTail
                return Format-Link $fullPath
            }

            'Absolute' {
                return Format-Link ( `
                    Join-Path $OriginPath $what.ReferenceTail `
                )
            }
        }
    }
}

function Get-MarkdownItemMovedContent {
    Param(
        [Parameter(ValueFromPipeline = $true)]
        $Source,

        $Destination,

        $Notebook
    )

    Process {
        if ($Source -is [String]) {
            $Source = Get-ChildItem $Source
        }

        foreach ($item in $Source) {
            $links = $item | Get-MarkdownLink -PassThru | where {
                $_.Type -eq 'Reference'
            } | where {
                $_.SearchMethod -eq 'Relative'
            }

            $cat = $Source | Get-Content

            foreach ($link in $links) {
                $capture = $link.MatchInfo.Matches[0].Groups[$link.Type]

                if ($link.Type -eq 'Web') {
                    continue
                }

                $newLink = ConvertTo-MarkdownLinkSearchMethod `
                    -OriginPath $link.FilePath `
                    -DestinationPath $link.Capture `
                    -SearchMethod Absolute

                $newLink = ConvertTo-MarkdownLinkSearchMethod `
                    -OriginPath $Destination `
                    -DestinationPath $newLink `
                    -SearchMethod Relative

                $matchInfo = $link.MatchInfo

                $cat[$matchInfo.LineNumber - 1] =
                    $matchInfo.Line.Substring(0, $capture.Index) `
                        + $newLink `
                        + $matchInfo.Line.Substring( `
                            $capture.Index + $capture.Length `
                        )
            }

            $moveItem = [PsCustomObject]@{
                Path = $Destination
                Content = $cat
                BackReferences = @()
            }

            $grep = dir $Notebook -Recurse `
                | Get-MarkdownLink -PassThru | where {
                    $_.Type -eq 'Reference'
                } | where {
                    $_.SearchMethod -eq 'Relative'
                } | where {
                    $_.Capture -match (Split-Path $Source -Leaf)
                }

            $cats = @{}

            foreach ($item in $grep) {
                if ($null -eq $cats[$item.FilePath]) {
                    $cats[$item.FilePath] = cat $item.FilePath
                }

                $matchInfo = $item.MatchInfo
                $capture = $matchInfo.Matches[0]

                $newLink = ConvertTo-MarkdownLinkSearchMethod `
                    -OriginPath $item.FilePath `
                    -DestinationPath $capture.Value `
                    -SearchMethod Absolute

                $newLink = ConvertTo-MarkdownLinkSearchMethod `
                    -OriginPath $item.FilePath `
                    -DestinationPath $newLink `
                    -SearchMethod Relative

                $cats[$matchInfo.Path][$matchInfo.LineNumber - 1] =
                    $matchInfo.Line.Substring(0, $capture.Index) `
                        + $newLink `
                        + $matchInfo.Line.Substring( `
                            $capture.Index + $capture.Length `
                        )
            }

            $moveItem.BackReferences = $cats.Keys | sort | foreach {
                [PsCustomObject]@{
                    Path = $_
                    Content = $cats[$_]
                }
            }

            return $moveItem
        }
    }
}
