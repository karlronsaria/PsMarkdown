
if ((Test-Path "\note\test")) {
    if ((Test-Path "\note\test\PsMarkdown")) {
        del \note\test\PsMarkdown -Recurse -Force
    }

    mkdir \note\test\PsMarkdown\
}
else {
    mkdir \note\test\
}

mkdir \note\test\PsMarkdown\TestA
mkdir \note\test\PsMarkdown\TestB\Test01
mkdir \note\test\PsMarkdown\TestC\Test01\Test_a
mkdir \note\test\PsMarkdown\TestD\Test01\Test_a

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

