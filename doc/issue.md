# issue

- [ ] 2023_04_09_151015
  - where
    - ``PsMarkdown#Link#Move-MarkdownItem``
  - actual

```powershell
C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsTool\note [master ≡]> Move-MarkdownItem .\todo_-_2022_03_23.md ..\doc\
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
