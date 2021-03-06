Function Start-RunCommand() {
    <#
    .SYNOPSIS
    Runs any commands passed into it.
    
    .DESCRIPTION
    Runs any commands passed into it, while capturing and handling their errors and exceptions.  It will then return whatever the native command would 
    return to STDOUT.  This command will also wait for the process and all of its children before returning. Uses the .Net libaries to start the process
    System.Diagnostics.ProcessStartInfo and System.Diagnostics.Process

    .INPUTS
    [ScriptBlock]$ScriptBlock - Parameter Set: ScriptBlock - Any native PowerShell commands passed in a ScriptBlock
    [String]$CMD - Parameter Set: Command - An executable that can launch on its own
    [String]$Args - Parameter Set: Command - Parameter to the executable
    [Long[]]$AcceptableReturnCodes - Parameter Set: Command - Defaults: 0, 3010 - Any acceptable return codes to the executable

    .OUTPUTS
    A PS Custom Object that contains the following fields:
        ScriptBlock - ScriptBlock of the PowerShell command to run
        CMD - String of the executable to call
        Args - String of the arguments to call on the executable
        AcceptableReturnCodes - Long array of the acceptable return codes
        InternalReturnCode = Long of the returncode of a CMD before being compared to the acceptable return codes
        Error - The error object returned by a ScriptBlock
        ErrorInvocationInfo - The Ps Invocation Info used when an error occurs
        ErrorScriptStackTrace - The PS Stack trace used when an error occurs
        ErrorMessage - String of the error message pass back from the ScriptBlock or function
        FoundReturnCode - Boolean if the internal return code was found in the acceptable return codes
        ReturnObj - Native object of the ScriptBlock return
        ReturnCode - Integer return code from the command, zero if successful and non-zero for failure
        Success - Boolean if the command succeeded

    .EXAMPLE
    This function allows you to run run native PowerShell code and will catch any errors or exceptions thrown by the called functions.
    Note that if you want to accept errors, then this function should not be used.


    Start-RunCommand -ScriptBlock {New-Item -Path "D:\HeaderTest" -ItemType Directory}
    This will return the following information back to the std out
        ScriptBlock           : New-Item -Path "D:\HeaderTest" -ItemType Directory
        CMD                   : 
        Args                  : 
        AcceptableReturnCodes : {0, 3010}
        PowerShellCommand     : 
        InternalReturnCode    : 0
        Error                 : 
        ErrorInvocationInfo   : 
        ErrorScriptStackTrace : 
        ErrorMessage          : 
        FoundReturnCode       : True
        ReturnObj             : D:\HeaderTest
        ReturnCode            : 0
        Success               : True


    [Void](Start-RunCommand -ScriptBlock {Remove-Item -Path "D:\HeaderTest" -Force})
    If you don't want any information return to std out then place [Void] in front of the command and place the command in parentheses
    


    .EXAMPLE
    This function also allows you to run exectuables with or without parameters. Note that full paths to executables must be passed in.  Relative paths and paths that
    reply on the "Path" environment variable do not work.
    
    Start-RunCommand -CMD "C:\Windows\System32\IPConfig.exe"
    This Returns output like the following format:
        ScriptBlock           : 
        CMD                   : C:\Windows\System32\IPConfig.exe
        Args                  : 
        AcceptableReturnCodes : {0, 3010}
        PowerShellCommand     : 
        InternalReturnCode    : 0
        Error                 : 
        ErrorInvocationInfo   : 
        ErrorScriptStackTrace : 
        ErrorMessage          : 
        FoundReturnCode       : True
        ReturnObj             : 
                                Windows IP Configuration
                        
                        
                                Ethernet adapter Local Area Connection 2:
                        
                                   Media State . . . . . . . . . . . : Media disconnected
                                   Connection-specific DNS Suffix  . : 
                        
                                Ethernet adapter Local Area Connection:
                        
                                   Connection-specific DNS Suffix  . : Lowes.com
                                   Link-local IPv6 Address . . . . . : XXXX::XXXX:XXXX:XXXX:XXXX%12
                                   IPv4 Address. . . . . . . . . . . : XXX.XXX.XXX.XXX
                                   Subnet Mask . . . . . . . . . . . : XXX.XXX.XXX.XXX
                                   Default Gateway . . . . . . . . . : XXX.XXX.XXX.XXX
                        
                                Ethernet adapter VirtualBox Host-Only Network:
                        
                                   Connection-specific DNS Suffix  . : 
                                   Link-local IPv6 Address . . . . . : XXXX::XXXX:XXXX:XXXX:XXXX%16
                                   IPv4 Address. . . . . . . . . . . : XXX.XXX.XXX.XXX
                                   Subnet Mask . . . . . . . . . . . : XXX.XXX.XXX.XXX
                                   Default Gateway . . . . . . . . . : 
                        
                                Tunnel adapter Local Area Connection* 12:
                        
                                   Media State . . . . . . . . . . . : Media disconnected
                                   Connection-specific DNS Suffix  . : 
                        
        ReturnCode            : 0
        Success               : True
    

    Start-RunCommand -CMD "C:\Windows\System32\Ping.exe" -Args "127.0.0.1"
    This Returns:
        ScriptBlock           : 
        CMD                   : C:\Windows\System32\Ping.exe
        Args                  : 127.0.0.1
        AcceptableReturnCodes : {0, 3010}
        PowerShellCommand     : 
        InternalReturnCode    : 0
        Error                 : 
        ErrorInvocationInfo   : 
        ErrorScriptStackTrace : 
        ErrorMessage          : 
        FoundReturnCode       : True
        ReturnObj             : 
                                Pinging 127.0.0.1 with 32 bytes of data:
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                        
                                Ping statistics for 127.0.0.1:
                                    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
                                Approximate round trip times in milli-seconds:
                                    Minimum = 0ms, Maximum = 0ms, Average = 0ms
                        
        ReturnCode            : 0
        Success               : True


    Start-RunCommand -CMD "C:\Windows\System32\Ping.exe" -Args "-n 6 -4 127.0.0.1"
    This returns: 
        ScriptBlock           : 
        CMD                   : C:\Windows\System32\Ping.exe
        Args                  : -n 6 -4 127.0.0.1
        AcceptableReturnCodes : {0, 3010}
        PowerShellCommand     : 
        InternalReturnCode    : 0
        Error                 : 
        ErrorInvocationInfo   : 
        ErrorScriptStackTrace : 
        ErrorMessage          : 
        FoundReturnCode       : True
        ReturnObj             : 
                                Pinging 127.0.0.1 with 32 bytes of data:
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                                Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                        
                                Ping statistics for 127.0.0.1:
                                    Packets: Sent = 6, Received = 6, Lost = 0 (0% loss),
                                Approximate round trip times in milli-seconds:
                                    Minimum = 0ms, Maximum = 0ms, Average = 0ms
                        
        ReturnCode            : 0
        Success               : True



    .EXAMPLE
    The Output of the function can be used to get the return objects of the the ScriptBlock that was run.


    $FileContents = (Start-RunCommand -ScriptBlock {Get-Content -Path $FileToGetContentFrom}).ReturnObj
    This will return the contents of the $FileToGetContentFrom file and place it in the $FileContents variable


    $ParentPath = (Start-RunCommand -ScriptBlock {Split-Path -Parent -Path (Get-Location)}).ReturnObj
    Thi will return the parent path of the the location and sets it to $ParentPath.  That means if the function comes back as Null that $ParentPath will
    be set to $Null.
    

    $PingResults = (Start-RunCommand -CMD Ping.exe -Args "127.0.0.1").ReturnObj
    This will return you ping results into the $PingResults, looking like:
        Pinging 127.0.0.1 with 32 bytes of data:
        Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
        Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
        Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
        Reply from 127.0.0.1: bytes=32 time<1ms TTL=128
                        
        Ping statistics for 127.0.0.1:
            Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
        Approximate round trip times in milli-seconds:
            Minimum = 0ms, Maximum = 0ms, Average = 0ms


    $PatchReturnCode = (Start-RunCommand -CMD "wusa.exe" -Args "`"$PkgExecutionDir\vendor\$MissingPatch`" /quiet /norestart" -AcceptableReturnCodes 0, 1, 1605, 1642, 3010, 2359302, -2145124329).InternalReturnCode
    This command is running a Windows patch silently and with no restart.  We are also passing in acceptable return codes for this exe.  We are then getting the return code
    passed back from the exe and storing that in $PatchReturnCode.  This allows us to create code based upon the return code of the exe.  In this situation if 
    0, 1, 1605, 1642, 3010, 2359302, -2145124329 is returned then the .ReturnCode would be 0.  


    $ReturnCode = (Start-RunCommand -CMD "$PkgExecutionDir\Vendor\Setup.exe" -Args "/sAll /rs /msi ISX_SERIALNUMBER=`"$AcrobatLicCode`" TRANSFORMS=`"AcroPro.mst`" /l*v `"$($Script:LOGPATH)\InstallMSI.log`"" -AcceptableReturnCodes 0, 3010).ReturnCode
    This allows us to get the return code of the fuction to make sure one of the acceptable codes was passed back.


    
    .NOTES
    NAME:    Start-RunCommand
    AUTHOR:   Adam Wickersham
    VERSION:  2.0
    LASTEDIT: 16Sep2014
    #>

    [CmdletBinding(DefaultParameterSetName='ScriptBlock')]
    Param(
        [Parameter(Mandatory=$True,
                   ParameterSetName='ScriptBlock')]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory=$True,
                   ParameterSetName='Command')]
        [ValidateNotNullOrEmpty()]
        [String]$CMD,

        [Parameter(Mandatory=$False,
                   ParameterSetName='Command')]
        [ValidateNotNullOrEmpty()]
        [String]$Args,

        [Parameter(Mandatory=$False,
                   ParameterSetName='Command')]
        [ValidateScript({([Long[]]$_).Length -ge 1})]
        [Long[]]$AcceptableReturnCodes = (0, 3010)
    )

    $CurrentRunCmdInfo = [PSCustomObject]@{
        ScriptBlock = $ScriptBlock
        CMD = $CMD
        Args = $Args
        AcceptableReturnCodes = $AcceptableReturnCodes
        InternalReturnCode = 0
        Error = $Null
        ErrorInvocationInfo = $Null
        ErrorScriptStackTrace = $Null
        ErrorMessage = $Null
        FoundReturnCode = $False
        ReturnObj = $Null
        ReturnCode = $Null
        Success = $True
    }

    If ($CurrentRunCmdInfo.CMD.Length -ne 0) { # CMD and Args
        Write-Debug "Start RunCommand with CMD: $($CurrentRunCmdInfo.CMD) and Args: $($CurrentRunCmdInfo.Args). AcceptableReturnCodes: $($CurrentRunCmdInfo.AcceptableReturnCodes)."
    }
    Else { # ScriptBlock
        Write-Debug "Start RunCommand with ScriptBlock: $($CurrentRunCmdInfo.ScriptBlock)."
    }

    Try {
        $ErrorActionPreference = "Stop"

        # Run all commands and capture their standard out
        If ($CurrentRunCmdInfo.ScriptBlock.Length -ne 0) {
            # Run the powershell command as a script block  
            $CurrentRunCmdInfo.ReturnObj = (& $CurrentRunCmdInfo.ScriptBlock)
        }
        Else { # Must be a Command and Arguments
            $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
            $ProcessInfo.FileName = $CurrentRunCmdInfo.CMD
            $ProcessInfo.RedirectStandardError = $True
            $ProcessInfo.RedirectStandardOutput = $True
            $ProcessInfo.UseShellExecute = $False
            If ($CurrentRunCmdInfo.Args.Length -ne 0) {
                $ProcessInfo.Arguments = $CurrentRunCmdInfo.Args
            }
            $Process = New-Object System.Diagnostics.Process
            $Process.StartInfo = $ProcessInfo
            $Process.Start() | Out-Null
            $CurrentRunCmdInfo.ReturnObj = $Process.StandardOutput.ReadToEnd() # These read lines need to before the wait for exit otherwise it causes a buffer overflow
            $CurrentRunCmdInfo.ErrorMessage = $Process.StandardError.ReadToEnd()
            $Process.WaitForExit()
            $CurrentRunCmdInfo.InternalReturnCode = $Process.ExitCode
        }

        $ErrorActionPreference = "Continue"
    }
    Catch {
        $ErrorActionPreference = "Continue" # Needed incase we hit an exception

        $CurrentRunCmdInfo.Error = $_
        $CurrentRunCmdInfo.ErrorInvocationInfo = $CurrentRunCmdInfo.Error.InvocationInfo
        $CurrentRunCmdInfo.ErrorScriptStackTrace = $CurrentRunCmdInfo.Error.ScriptStackTrace
        $CurrentRunCmdInfo.Success = $False
        
        If (($CurrentRunCmdInfo.InternalReturnCode -eq 0) -and ($CurrentRunCmdInfo.ReturnObj.Length -eq 0)) {
            $CurrentRunCmdInfo.InternalReturnCode = -100
        }
        
        If ($CurrentRunCmdInfo.CMD.Length -ne 0) { # CMD and Args
            $CurrentRunCmdInfo.ErrorMessage = "Failed to run CMD: $($CurrentRunCmdInfo.CMD) and Args: $($CurrentRunCmdInfo.Args). With Error: $($CurrentRunCmdInfo.Error.ToString()). Error Code: $($CurrentRunCmdInfo.InternalReturnCode). Return Object: $($CurrentRunCmdInfo.ReturnObj)"
        }
        Else { # ScriptBlock
            $CurrentRunCmdInfo.ErrorMessage = "Failed to run ScriptBlock: $($CurrentRunCmdInfo.ScriptBlock). With Error: $($CurrentRunCmdInfo.Error.ToString()). Error Code: $($CurrentRunCmdInfo.InternalReturnCode). Return Object: $($CurrentRunCmdInfo.ReturnObj)"
        }
        Write-Verbose "Error: $($CurrentRunCmdInfo.Error). InvocationInfo: $($CurrentRunCmdInfo.ErrorInvocationInfo). StackTrace: $($CurrentRunCmdInfo.ErrorScriptStackTrace)"
    }
    Finally {
        # Check to see if the return code was one of the acceptable ones
        Foreach($Code In $CurrentRunCmdInfo.AcceptableReturnCodes) {
            If ($CurrentRunCmdInfo.InternalReturnCode -eq $Code) {
                Write-Verbose "Found ErrorCode $($CurrentRunCmdInfo.InternalReturnCode) in Acceptable Return Codes: $($CurrentRunCmdInfo.AcceptableReturnCodes).  Exiting For Loop."
                $CurrentRunCmdInfo.FoundReturnCode = $True
                $CurrentRunCmdInfo.ReturnCode = 0
                Break
            }
        }

        If ($CurrentRunCmdInfo.CMD.Length -ne 0) {
            If ($CurrentRunCmdInfo.FoundReturnCode -eq $False) {
                $CurrentRunCmdInfo.Success = $False
                $CurrentRunCmdInfo.ReturnCode = $CurrentRunCmdInfo.InternalReturnCode
            }
        }

        # Create and Write the message to the log if there was an error and set the global return code
        If ($CurrentRunCmdInfo.FoundReturnCode -eq $False) {
            If ($CurrentRunCmdInfo.ErrorMessage.Length -eq 0) {
                Write-Verbose "No exception was thrown, creating error message with just the return code from the command."
                If ($CurrentRunCmdInfo.CMD.Length -ne 0) { # CMD and Args
                    $CurrentRunCmdInfo.ErrorMessage = "Failed to run CMD: $($CurrentRunCmdInfo.CMD) and Args: $($CurrentRunCmdInfo.Args). Error Code: $($CurrentRunCmdInfo.InternalReturnCode)"
                }
                Else { # ScriptBlock
                    $CurrentRunCmdInfo.ErrorMessage = "Failed to run ScriptBlock: $($CurrentRunCmdInfo.ScriptBlock). Error Code: $($CurrentRunCmdInfo.InternalReturnCode)"
                }
            }
            Write-Error -Message "Error found during execution: $($CurrentRunCmdInfo.ErrorMessage)"
        }

        If ($CurrentRunCmdInfo.CMD.Length -ne 0) { # CMD and Args
            Write-Debug "End RunCommand with CMD: $($CurrentRunCmdInfo.CMD) and Args: $($CurrentRunCmdInfo.Args). AcceptableReturnCodes: $($CurrentRunCmdInfo.AcceptableReturnCodes). Returning $CurrentRunCmdInfo"
        }
        Else { # ScriptBlock
            Write-Debug "End RunCommand with ScriptBlock: $($CurrentRunCmdInfo.ScriptBlock). Returning $CurrentRunCmdInfo"
        }

    }

    Return $CurrentRunCmdInfo
} # Function Start-RunCommand() {
