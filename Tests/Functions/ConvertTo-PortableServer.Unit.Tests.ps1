#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2.0"; MaximumVersion = "6.999" }

Describe 'ConvertTo-PortableServer' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"

        $script:moduleToTest = Initialize-TestEnvironment
    }

    InModuleScope AtlassianPS.Configuration {
        It 'enforces the shared contract at its boundary' {
            $server = [AtlassianPS.ServerData]@{
                Id      = 1
                Name    = 'test'
                Uri     = 'https://jira.example.com'
                Type    = 'Jira'
                Session = 'sentinel'
            }
            $portable = ConvertTo-PortableServer -Server $server

            @($portable.Keys) | Should -HaveCount 4
            $portable.Keys | Should -Not -Contain Session
            $server.Headers = @{ Cookie = 'sentinel' }

            { ConvertTo-PortableServer -Server $server } | Should -Throw
        }
    }
}
