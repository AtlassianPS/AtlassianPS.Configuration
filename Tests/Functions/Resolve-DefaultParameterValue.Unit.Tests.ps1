#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.9.0"; MaximumVersion = "5.9.999" }

Describe "Resolve-DefaultParameterValue" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        It "resolves matching defaults only" {
            $reference = @{
                "Invoke-WebRequest:TimeoutSec" = 30
                "Invoke-RestMethod:TimeoutSec" = 15
                "*:Verbose"                    = $true
            }

            $resolved = Resolve-DefaultParameterValue `
                -Reference $reference `
                -CommandName "Invoke-WebRequest" `
                -ParameterName "TimeoutSec", "Verbose"

            $resolved["Invoke-WebRequest:TimeoutSec"] | Should -Be 30
            $resolved["Invoke-WebRequest:Verbose"] | Should -Be $true
            $resolved.Keys | Should -Not -Contain "Invoke-RestMethod:TimeoutSec"
        }
    }
}

