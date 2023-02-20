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

            $iList = $InputString.Replace('\', '/').Split('/')
            $rList = $ReferenceString.Replace('\', '/').Split('/')
            $iEnum = 0
            $rEnum = 0
            $prefix = @()

            while ($iEnum -lt $iList.Count -and $rEnum -lt $rList.Count) {
                if ($iList[$iEnum] -ne $rList[$rEnum]) {
                    break
                }

                $prefix += @($iList[$iEnum])
                $iEnum++
                $rEnum++
            }

            $iTail = @()

            while ($iEnum -lt $iList.Count) {
                $iTail += @($iList[$iEnum])
                $iEnum++
            }

            $rTail = @()

            while ($rEnum -lt $rList.Count) {
                $rTail += @($rList[$rEnum])
                $rEnum++
            }

            return [PsCustomObject]@{
                Prefix = $prefix -Join '/'
                InputTail = $iTail -Join '/'
                ReferenceTail = $rTail -Join '/'
            }
        }

        function Format-Link {
            Param(
                [Parameter(ValueFromPipeline = $true)]
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
                if ($null -ne $dir -and $dir.Mode -match '^-a') {
                    $OriginPath = Split-Path $OriginPath -Parent
                }

                $originList =
                    $OriginPath.Replace('\', '/').Split('/')

                $refTailList =
                    $what.ReferenceTail.Replace('\', '/').Split('/')

                if ($refTailList[0] -eq '.') {
                    $refTailList = $refTailList[1 .. ($refTailList.Count - 1)]
                }

                while ($refTailList[0] -eq '..' `
                    -and $originList.Count -gt 0)
                {
                    $refTailList = if ($refTailList.Count -eq 1) {
                        @()
                    } else {
                        $refTailList[1 .. ($refTailList.Count - 1)]
                    }

                    $originList = if ($originList.Count -eq 1) {
                        @()
                    } else {
                        $originList[0 .. ($originList.Count - 2)]
                    }
                }

                return Join-Path `
                    ($originList -Join '/') `
                    ($refTailList -Join '/') `
                    | Format-Link
            }
        }
    }
}

function Move-MarkdownItem {
    Param(
        [String]
        $Source,

        [String]
        $Destination,

        [Switch]
        $Force,

        $Notebook
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

                if ((Get-Item $Destination).Mode -like "d*") {
                    $Destination =
                        Join-Path $Destination (Split-Path $Source -Leaf)
                }

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

                    $newLine =
                        $matchInfo.Line.Substring(0, $capture.Index) `
                            + $newLink `
                            + $matchInfo.Line.Substring( `
                                $capture.Index + $capture.Length `
                            )

                    $cat[$matchInfo.LineNumber - 1] = $newLine
                }

                $moveItem = [PsCustomObject]@{
                    Path = $Destination
                    Content = $cat
                    BackReferences = @()
                    ChangeLinks = @(
                        [PsCustomObject]@{
                            'FilePath' = $Destination
                            'LineNumber' = $matchInfo.LineNumber
                            'Old' = $matchInfo.Line
                            'New' = $newLine
                        }
                    )
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
                        -DestinationPath $Destination `
                        -SearchMethod Relative

                    $newLine =
                        $matchInfo.Line.Substring(0, $capture.Index) `
                            + $newLink `
                            + $matchInfo.Line.Substring( `
                                $capture.Index + $capture.Length `
                            )

                    $cats[$matchInfo.Path][$matchInfo.LineNumber - 1] =
                        $newLine
                }

                $moveItem.BackReferences = $cats.Keys | sort | foreach {
                    [PsCustomObject]@{
                        Path = $_
                        Content = $cats[$_]
                    }
                }

                $moveItem.ChangeLinks += @(
                    [PsCustomObject]@{
                        'FilePath' = $item.FilePath
                        'LineNumber' = $matchInfo.LineNumber
                        'Old' = $matchInfo.Line
                        'New' = $newLine
                    }
                )

                return $moveItem
            }
        }
    }

    if (-not $Notebook) {
        $settingFile = "$PsScriptRoot/../res/setting.json"

        if ((Test-Path $settingFile)) {
            $Notebook = (cat $settingFile | ConvertFrom-Json).Notebook
        }
    }

    $dir = (Get-Item $Source).Directory

    $resource = Get-MarkdownLocalResource `
        -ItemPath $Source

    $moveLinkInfo = @()

    if ($Notebook) {
        $moveLinkInfo = Get-MarkdownItemMovedContent `
            -Source $Source `
            -Destination $Destination `
            -Notebook $Notebook
    }

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

    if ((Get-Item $Destination).Mode -like "d*") {
        $Destination = Join-Path $Destination (Split-Path $Source -Leaf)
    }

    if ($Notebook) {
        $moveLinkInfo.Content | Out-File $Destination -Force

        if (diff ($moveLinkInfo.Content) (cat $Destination)) {
            Write-Warning "Failed to write file $($Destination)"
        }
        else {
            Write-Output $moveLinkInfo.ChangeLinks[0]
        }

        foreach ($backRef in $moveLinkInfo.BackReferences) {
            $backRef.Content | Out-File $backRef.Path -Force

            if (diff ($backRef.Content) (cat $backRef.Path)) {
                Write-Warning "Failed to write file $($backRef.Path)"
            }
            else {
                Write-Output $moveLinkInfo.ChangeLinks | where {
                    $_.FilePath -eq $backRef.Path
                }
            }
        }
    }
}
