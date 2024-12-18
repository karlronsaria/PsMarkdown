#Requres -Module Pester

Describe 'Move-MarkdownItem' {
    BeforeAll {
        function Get-PsMarkdownMoveTestPath {
            $path = (cat "$PsScriptRoot\..\res\setting.json" `
                | ConvertFrom-Json).Link.Notebook

            if ((Get-Item $path).Mode -notlike "d*") {
                $path = Split-Path $path -Parent
            }

            return $path
        }

        function New-PsMarkdownMoveTest {
            $path = Get-PsMarkdownMoveTestPath

            if ((Test-Path "\note\test")) {
                if ((Test-Path "\note\test\PsMarkdown")) {
                    del "$path\test\PsMarkdown" -Recurse -Force
                }

                mkdir "$path\test\PsMarkdown\"
            }
            else {
                mkdir "$path\test\"
            }

            mkdir "$path\test\PsMarkdown\TestA"
            mkdir "$path\test\PsMarkdown\TestB\Test01"
            mkdir "$path\test\PsMarkdown\TestC\Test01\Test_a"
            mkdir "$path\test\PsMarkdown\TestD\Test01\Test_a"

            $out = @"
# master file

- [Sus](./TestA/sus.md)

- [Ihr](./TestB/Test01/ihr.md)

- [Oth](./TestC/Test01/Test_a/oth.md)
"@

            $out | Out-File "\note\test\PsMarkdown\master.md"

            $out = @"
# sus file

- [Ihr](./../TestB/Test01/ihr.md)

- [Oth](./../TestC/Test01/Test_a/oth.md)
"@

            $out | Out-File "\note\test\PsMarkdown\TestA\sus.md"

            $out = @"
# ihr file

- [Sus](./../../TestA/sus.md)

- [Oth](./../../TestC/Test01/Test_a/oth.md)
"@

            $out | Out-File "\note\test\PsMarkdown\TestB\Test01\ihr.md"

            $out = @"
# oth file

- [Sus](./../../../TestA/sus.md)

- [Ihr](./../../../TestB/Test01/ihr.md)
"@

            $out | Out-File "\note\test\PsMarkdown\TestC\Test01\Test_a\oth.md"
        }

        function Get-PsMarkdownMoveTestTree {
            $path = "$(Get-PsMarkdownMoveTestPath)/test/PsMarkdown"
            $tree = (dir (Join-Path $path "*.md") -Recurse).FullName | Sort-Object
            return $tree
        }

        function Get-PsMarkdownMoveTestContent {
            Param(
                [Switch]
                $PassThru
            )

            $tree = Get-PsMarkdownMoveTestTree
            $cat = dir $tree | Get-Content

            if ($PassThru) {
                [PsCustomObject] @{
                    Tree = $tree
                    Content = $cat
                }
            }
            else {
                [PsCustomObject] @{
                    Content = $cat
                }
            }
        }
    }

    It 'Given a Notebook argument, changes links and backreference links accurately' {
        New-PsMarkdownMoveTest | Out-Null
        $path = "$(Get-PsMarkdownMoveTestPath)/test/PsMarkdown"
        $params = (cat "$PsScriptRoot/Move-MarkdownItem.Params.json" `
            | ConvertFrom-Json).Param

        $params = $params[0]

        $what = Move-MarkdownItem `
            -Source (Join-Path $path $params.Source) `
            -Destination (Join-Path $path $params.Destination)

        $diff = Compare-Object `
            (Get-PsMarkdownMoveTestContent -PassThru) `
            (cat "$PsScriptRoot/Move-MarkdownItem.After.001.json" `
                | ConvertFrom-Json)

        $diff | Should Be $null
    }
}

