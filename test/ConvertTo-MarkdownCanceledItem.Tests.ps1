#Requres -Module Pester

Describe 'ConvertTo-MarkdownCanceledItem' {
    BeforeAll {
        . "$PsScriptRoot/../demand/Worklist.ps1"
    }

    Context "From Pipeline" {
        It "Given valid input" -TestCases $(
            Get-Item `
                "$PsScriptRoot/ConvertTo-MarkdownCanceledItem.Mock.json" |
            Get-Content |
            ConvertTo-Json |
            foreach { $_.Mock }
        ) {
            Param(
                $In,
                $Expected
            )

            $($In | ConvertTo-MarkdownCanceledItem) | Should Be $Expected
        }
    }
}

