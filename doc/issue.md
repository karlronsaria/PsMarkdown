# issue

- [ ] 2025-03-31-174935
  - where: ``Move-MarkdownItem``
  - howto

    ```powershell
    Move-MarkdownItem .\journal_-_2025-03-31_demo_MinecraftMassLogin.md .\emp\journal\
    ```

  - actual

    ```text
        Directory: C:\note\emp\journal
    
    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    d----           3/31/2025  5:41 PM                res
    Move-Item: C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:672
    Line |
     672 |          Move-Item `
         |          ~~~~~~~~~~~
         | Cannot find path 'C:\note\res\g3_3_31_2025_2_38_21_PM.png' because it does not exist.
    Move-Item: C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:672
    Line |
     672 |          Move-Item `
         |          ~~~~~~~~~~~
         | Cannot find path 'C:\note\res\Minecraft_Launcher_3_31_2025_2_27_37_PM.png' because it does not exist.
    
    FilePath   : C:\note\emp\journal\journal_-_2025-03-31_demo_MinecraftMassLogin.md
    LineNumber :
    Old        :
    New        :
    ```

    None of the locals appear to be broken

- [x] 2025-02-22-005302
  - where: ``PsMarkdown#ClipImage#Save-...``
  - howto

    With non-resolvable text on the clipboard

    ```powershell
    Save-ClipboardToImageFormat -BasePath .
    ```

  - actual

    ```text
    Write-Error: C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\ClipImage.ps1:235
    Line |
     235 |              $result = Save-FileByTextClip `
         |                        ~~~~~~~~~~~~~~~~~~~~~
         | No file found at set "command=%comamnd%; Out-Toast

    Success Path MarkdownString Format
    ------- ---- -------------- ------
       True                     Text
    ```

  - expected

    ```text
    Write-Error: C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\ClipImage.ps1:235
    Line |
     235 |              $result = Save-FileByTextClip `
         |                        ~~~~~~~~~~~~~~~~~~~~~
         | No file found at set '"command=%comamnd%; Out-Toast'

    Success Path MarkdownString Format
    ------- ---- -------------- ------
      False                     Text
    ```

- [x] 2025-02-17-001910
  - where: ``Link#Select-MarkdownResource``
  - howto

    ![2025-02-17-001940](./res/2025-02-17-001940.png)

  - actual

    ```text
    InvalidOperation: C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:745
    Line |
     745 |          foreach { $fullPaths[$_] }
         |                    ~~~~~~~~~~~~~~
         | Index operation failed; the array index evaluated to null.
    ```

- [x] 2024-09-18-230753
  - where
    - In VsCode
    - ``PsMarkdown#ClipImage#Save-...``
  - howto
    - copy image to clipboard from browser or file explorer
  - actual
    - no action

- [x] 2024-05-10-025039
  - where
    - ``PsMarkdown#ClipImage#Save-...``
  - actual
    - images placed in same folder as document instead of ``./res`` subfolder

- [x] 2024-04-22-203047
  - where
    - ``PsMarkdown#Grep#MdLink``
  - log

    ```powershell
    cd \note
    cd .\kinesiology\
    dir *.md -Recurse | sls biceps
    dir *.md -Recurse | sls biceps | mdlink -all | open
    dir *.md -Recurse | sls biceps | mdlink -all
    dir *.md -Recurse | sls biceps | select -unique
    dir *.md -Recurse | sls biceps | group -Property Path
    dir *.md -Recurse | sls biceps | group -Property Path | what Name
    dir *.md -Recurse | sls biceps | group -Property Path | what Name | mdlink
    dir *.md -Recurse | sls biceps | group -Property Path | what Name | mdlink -All
    get-history | clip
    get-history
    ```

- [x] 2023-11-09-230331
  - where
    - ``PsMarkdown#Link#Get-MarkdownLink``
  - actual

    ```text
    typename F
    F(T)
    F(T)
    int
    int
    int
    decltype(add)(int, int)
    int
    typename U, typename F

    ...

    kbd
    kbd
    kbd
    kbd
    kbd
    kbd
    ```

- [x] 2023-11-14-234154
  - where
    - ``PsMarkdown#ClipImage#Save-ClipboardToImageFormat``
  - howto
    - <kb>Alt</kb> + <kb>PrtSc</kb>

    - ```powershell
      Save-ClipboardToImageFormat `
          -BasePath . `
          -FolderName __temp `
          -FileName sus `
          -FileExtension png
      ```

  - actual

    ```
    Save-ClipboardToImageFormat : No file found at System.Drawing.Bitmap
    At line:1 char:1
    + Save-ClipboardToImageFormat -BasePath . -FolderName __temp -FileName  ...
    + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorExcept
       ion
        + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException
       ,Save-ClipboardToImageFormat


    Success Path MarkdownString Format
    ------- ---- -------------- ------
       True                     Image
    ```

- [x] 2023-08-09-010903

  - where
    - ``PsMarkdown#Link#Move-MarkdownItem``
  - actual
    ```
    C:\note [master ≡]> Move-MarkdownItem -Source .\watch_-_2023-02-07.md -Destination .\watch\__COMPLETE\
    The variable '$matchInfo' cannot be retrieved because it has not been set.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:489 char:44
    +                             'LineNumber' = $matchInfo.LineNumber
    +                                            ~~~~~~~~~~
        + CategoryInfo          : InvalidOperation: (matchInfo:String) [], RuntimeException
        + FullyQualifiedErrorId : VariableIsUndefined
    
    The property 'BackReferences' cannot be found on this object. Verify that the property exists and can
    be set.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:536 char:17
    + ...              $moveItem.BackReferences = $cats.Keys | sort | foreach {
    +                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
        + FullyQualifiedErrorId : PropertyNotFound
    
    The property 'ChangeLinks' cannot be found on this object. Verify that the property exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:543 char:17
    +                 $moveItem.ChangeLinks += @(
    +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict
    
    The property 'Content' cannot be found on this object. Verify that the property exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:607 char:9
    +         $moveLinkInfo.Content | Out-File $Destination -Force
    +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict
    
    The property 'Content' cannot be found on this object. Verify that the property exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:609 char:13
    +         if (diff ($moveLinkInfo.Content) (cat $Destination)) {
    +             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict
    
    The property 'BackReferences' cannot be found on this object. Verify that the property exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:616 char:30
    +         foreach ($backRef in $moveLinkInfo.BackReferences) {
    +                              ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict
    ```

- [x] 2023-05-02-203733

  - where
    - ``PsMarkdown#Link#Move-MarkdownItem``
  - actual

    ```
    C:\note [master ≡ +4 ~4 -0 !]> Move-MarkdownItem .\pool_-_2023-01-26.md C:\note\d
    rawboard
    The variable '$matchInfo' cannot be retrieved because it has not been set.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:480 char:44
    +                             'LineNumber' = $matchInfo.LineNumber
    +                                            ~~~~~~~~~~
        + CategoryInfo          : InvalidOperation: (matchInfo:String) [], RuntimeE
       xception
        + FullyQualifiedErrorId : VariableIsUndefined

    The property 'BackReferences' cannot be found on this object. Verify that the
    property exists and can be set.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:527 char:17
    + ...              $moveItem.BackReferences = $cats.Keys | sort | foreach {
    +                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
        + FullyQualifiedErrorId : PropertyNotFound

    The property 'ChangeLinks' cannot be found on this object. Verify that the
    property exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:534 char:17
    +                 $moveItem.ChangeLinks += @(
    +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict

        Directory: C:\note\drawboard

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    d-----          5/2/2023   8:34 PM                res
    The property 'Content' cannot be found on this object. Verify that the property
    exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:598 char:9
    +         $moveLinkInfo.Content | Out-File $Destination -Force
    +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict

    The property 'Content' cannot be found on this object. Verify that the property
    exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:600 char:13
    +         if (diff ($moveLinkInfo.Content) (cat $Destination)) {
    +             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict

    The property 'BackReferences' cannot be found on this object. Verify that the
    property exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:607 char:30
    +         foreach ($backRef in $moveLinkInfo.BackReferences) {
    +                              ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict
    ```

- [x] 2023-04-09-151015
  - where
    - ``PsMarkdown#Link#Move-MarkdownItem``
  - actual

    ```
    C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsTool\note [master ≡]> Move-MarkdownItem .\todo_-_2022-03-23.md ..\doc\
    The variable '$matchInfo' cannot be retrieved because it has not been set.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:480 char:44
    +                             'LineNumber' = $matchInfo.LineNumber
    +                                            ~~~~~~~~~~
        + CategoryInfo          : InvalidOperation: (matchInfo:String) [], RuntimeE
       xception
        + FullyQualifiedErrorId : VariableIsUndefined

    The property 'BackReferences' cannot be found on this object. Verify that the
    property exists and can be set.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:527 char:17
    + ...              $moveItem.BackReferences = $cats.Keys | sort | foreach {
    +                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
        + FullyQualifiedErrorId : PropertyNotFound

    The property 'ChangeLinks' cannot be found on this object. Verify that the
    property exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:534 char:17
    +                 $moveItem.ChangeLinks += @(
    +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict

        Directory:
        C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsTool\doc

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    d-----          4/9/2023   3:07 PM                res
    The property 'Content' cannot be found on this object. Verify that the property
    exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:598 char:9
    +         $moveLinkInfo.Content | Out-File $Destination -Force
    +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict

    The property 'Content' cannot be found on this object. Verify that the property
    exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:600 char:13
    +         if (diff ($moveLinkInfo.Content) (cat $Destination)) {
    +             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict

    The property 'BackReferences' cannot be found on this object. Verify that the
    property exists.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script
    \Link.ps1:607 char:30
    +         foreach ($backRef in $moveLinkInfo.BackReferences) {
    +                              ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], PropertyNotFoundException
        + FullyQualifiedErrorId : PropertyNotFoundStrict

    C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsTool\note [master ≡ +2 ~0 -3 !]> dir

        Directory:
        C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsTool\note

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    da---l          4/9/2023   3:07 PM                res

    C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsTool\note [master ≡ +2 ~0 -3 !]>
    ```

- [x] 2023-09-07-201444

  - where
    - ``PsMarkdown#Link#Get-MarkdownLinkSparse``
  - actual
    ```
    C:\note [master ≡ +0 ~3 -0 !]> dir *.md -Recurse | sls cbc | mdlink
    F, spoke over intercom
    ```

- [x] 2023-09-07-210457

  - where
    - ``PsMarkdown#Link#Get-MarkdownLinkSparse``
  - howto
    - ``cd \note; dir *.md -Recurse | sls cbc | mdlink -TestWebLink``
  - actual
    - takes a while to halt

- [x] 2023-09-06-003943

  - where
    - ``PsMarkdown#Link#Get-MarkdownLinkSparse``
  - actual
    ```
    C:\note\todo [master ≡ +2 ~3 -0 !]> dir *.md | mdlink
    Index was outside the bounds of the array.
    At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsMarkdown\script\Link.ps1:41 char:13
    +             @($links)[0]
    +             ~~~~~~~~~~~~
        + CategoryInfo          : OperationStopped: (:) [], IndexOutOfRangeException
        + FullyQualifiedErrorId : System.IndexOutOfRangeException
    ```

---
[← Go Back](../readme.md)
