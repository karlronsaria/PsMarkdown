function Select-MarkdownString {
    [Alias('slms')]
    [CmdletBinding(
        DefaultParameterSetName='File',
        HelpUri='https://go.microsoft.com/fwlink/?LinkID=2097119'
    )]
    Param(
        [ValidateNotNull()]
        [string]
        ${Culture} = 'Current',

        [Parameter(ParameterSetName='Object', Mandatory=$true, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='ObjectRaw', Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [AllowEmptyString()]
        [PsObject]
        ${InputObject},

        [Parameter(Mandatory=$true, Position=0)]
        [string[]]
        ${Pattern},

        [Parameter(ParameterSetName='File', Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='FileRaw', Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='LiteralFile', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='LiteralFileRaw', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath','LP')]
        [string[]]
        ${LiteralPath},

        [Parameter(ParameterSetName='ObjectRaw', Mandatory=$true)]
        [Parameter(ParameterSetName='FileRaw', Mandatory=$true)]
        [Parameter(ParameterSetName='LiteralFileRaw', Mandatory=$true)]
        [switch]
        ${Raw},

        [switch]
        ${SimpleMatch},

        [switch]
        ${CaseSensitive},

        [Parameter(ParameterSetName='Object')]
        [Parameter(ParameterSetName='File')]
        [Parameter(ParameterSetName='LiteralFile')]
        [switch]
        ${Quiet},

        [switch]
        ${List},

        [switch]
        ${NoEmphasis},

        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Include},

        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Exclude},

        [switch]
        ${NotMatch},

        [switch]
        ${AllMatches},

        [ValidateNotNullOrEmpty()]
        [System.Text.Encoding]
        ${Encoding},

        [ValidateNotNullOrEmpty()]
        [ValidateCount(1, 2)]
        [ValidateRange(0, 2147483647)]
        [int[]]
        ${Context}
    )

    Begin {
        $outBuffer = $null

        if ($PsBoundParameters.TryGetValue(
            'OutBuffer',
            [ref] $outBuffer
        )) {
            $PsBoundParameters['OutBuffer'] = 1
        }

        $map = [ordered]@{}
        $myList = @()
    }

    Process {
        $mainInput = switch -Regex ($PsCmdlet.ParameterSetName) {
            "Object(Raw)?" { $InputObject }
            "File(Raw)?" { $File }
            "LiteralFile(Raw)?" { $LiteralFile }
        }

        if ($mainInput -is [string]) {
            $myList += @($InputObject)
            return
        }

        foreach ($item in @(Select-String @PsBoundParameters)) {
            $map[$item.Path] =
                @($map[$item.Path] | where { $_ }) +
                @($item)
        }
    }

    End {
        function Get-CodeBlockRange {
            Param(
                [Parameter(ValueFromPipelineByPropertyName = $true)]
                [int]
                $LineNumber,

                [Parameter(ValueFromPipelineByPropertyName = $true)]
                [string[]]
                $Lines
            )

            Process {
                ($LineNumber - 1) .. ($LineNumber + $Lines.Count)
            }
        }

        $codeBlockRange = $myList |
            Get-MdCodeBlock |
            Get-CodeBlockRange

        $params = $PsBoundParameters.PsObject.Copy()
        [void] $params.Remove('InputObject')

        $myList |
            Select-String @params |
            where {
                $_.LineNumber -notin $codeBlockRange
            }

        foreach ($key in $map.Keys) {
            $codeBlockRange = $key |
                Get-ChildItem |
                Get-Content |
                Get-MdCodeBlock |
                Get-CodeBlockRange

            $map[$key] | where {
                $_.LineNumber -notin $codeBlockRange
            }
        }
    }
}
