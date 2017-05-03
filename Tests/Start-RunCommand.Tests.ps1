$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).TrimEnd('Tests')
$sut = "Start-RunCommand"
Import-Module "$here$sut" -Force


Describe "Start-RunCommand" {
    It "Should handle a script block" {
        $Result = Start-RunCommand -ScriptBlock {Ping 127.0.0.1}
        $Result.Success | Should Be $True
    }

    It "Should handle a cmd and args" {
        $Result = Start-RunCommand -CMD "Ping.exe" -Args "127.0.0.1"
        $Result.Success | Should Be $True
    }

    It "Should handle a cmd without args" {
        $Result = Start-RunCommand -CMD "IPConfig.exe"
        $Result.Success | Should Be $True
    }

    It "Should handle a cmd, args and unique acceptable return codes" {
        $Result = Start-RunCommand -CMD "CMD.exe" -Args "/C Exit 1234" -AcceptableReturnCodes 0, 3010, 5, 99, 1234
        $Result.ReturnCode | Should Be 0
    }

    It "Should return a pscustom object and have ReturnObj ( Success and ReturnCode are tested above)" {  
        $Result = Start-RunCommand -CMD "Ping.exe" -Args "127.0.0.1"
        Write-Warning $Result.ReturnObj.GetType()
        $Result.ReturnObj.Contains("Pinging 127.0.0.1 with 32 bytes of data:") | Should Be $True
    }

    It "Should not fail if to much data is returned from CMD" {
        $Result = Start-RunCommand -CMD "CMD.exe" -Args "/C for /L %a in (1,1,10000) do (echo %a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a%a)"
        Write-Warning $Result.ReturnObj.Length
        $Result.Success | Should Be $True
    }

    It "Should fail if cmd and scriptblock is returned" {
        { Start-RunCommand -CMD "Ping.exe" -Args "127.0.0.1" -ScriptBlock {ipconfig} -AcceptableReturnCodes 0, 3010 } | Should Throw
    }

    It "Should fail if the is a 'error' in the scriptblock" {
        $Result = Start-RunCommand -ScriptBlock {Throw "erroring"}
        $Result.Success | Should Be $False
    }

    It "Should fail if the is a 'error' in the CMD" {
        $Result = Start-RunCommand -CMD "Ping.exe"
        $Result.ReturnCode | Should Be 1
    }

    It "Should fail with return code not in the acceptable list for CMD" {
        $Result = Start-RunCommand -CMD "Ping.exe"
        $Result.Success | Should Be $False
    }
}