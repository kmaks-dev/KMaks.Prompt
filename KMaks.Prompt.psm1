function prompt {
    [CmdletBinding()]
    param ()
    
    $IsAdmin = if ($IsWindows) {
        (
            [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    # Set-PSReadLineOption -PromptText @("> ","# ")[[Security.Principal.WindowsIdentity]::GetCurrent().Groups.Value.Contains("S-1-5-32-544")]
    }
    elseif ($IsLinux) { 0 -eq (id -u) }
    elseif ($IsMacOS) { 0 -eq (id -u) }

    $Identity = if ([System.Environment]::UserDomainName -ne [System.Environment]::MachineName) {
        $Identity = "{0}\" -f [System.Environment]::UserDomainName
    }
    $Identity += "{0}@{1}" -f [System.Environment]::UserName, [System.Environment]::MachineName

    Set-PSReadLineOption -PromptText @("> ","# ")[$IsAdmin]
    Set-PSReadLineOption -ContinuationPrompt (">>    {0}" -f $(" " * ($nestedPromptLevel + 1)))
    $host.ui.RawUI.WindowTitle = $Identity
    $PSReadLineOption = Get-PSReadLineOption

    $Path       = "{0}{1}" -f $PSReadLineOption.KeywordColor,
                                $ExecutionContext.SessionState.Path.CurrentLocation.ProviderPath.Replace($Home, "~")
    $Timestamp  = "`e[2m{0}{1}`e[0m" -f $PSReadLineOption.CommandColor,
                                [datetime]::Now.ToString('dd.MM.yyyy, HH:mm:ss')
    $HostInfo   = "{0}{1}" -f $PSReadLineOption.StringColor,
                                $Identity
    $PSVersion  = "{0}PS{1}{2}.{3}" -f $PSReadLineOption.TypeColor,
                                        $PSReadLineOption.EmphasisColor,
                                        $PSVersionTable.PSVersion.Major,
                                        $PSVersionTable.PSVersion.Minor
    $Prompt     = "{0}{1}" -f $PSReadLineOption.TypeColor,
                                [string]$PSReadLineOption.PromptText

    "`r" +
    "${Timestamp} ${Path}`n" +
    "${PSVersion}${Prompt}"
}
