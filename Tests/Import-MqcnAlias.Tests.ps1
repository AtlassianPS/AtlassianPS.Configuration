#requires -module Pester

Describe "Import-MqcnAlias" {

    Import-Module (Join-Path $PSScriptRoot "../AtlassianPS.Configuration") -Force -ErrorAction Stop

    InModuleScope AtlassianPS.Configuration {
        #region Mocking
        #endregion Mocking

        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name Import-MqcnAlias

            It "has a [String] -Alias parameter" {
                $command.Parameters.ContainsKey("Alias")
                $command.Parameters["Alias"].ParameterType | Should Be "String"
            }
            It "has a [String] -Command parameter" {
                $command.Parameters.ContainsKey('Command')
                $command.Parameters["Command"].ParameterType | Should Be "String"

            }
        }

        Context "Behavior checking" {
            It "creates an alias in the module's scope" {
                Import-MqcnAlias -Alias "aa" -Command "Microsoft.PowerShell.Management\Get-Item"
                Get-Alias -Name "aa" -Scope "Local" -ErrorAction Ignore | Should Be $true
            }
            It "does not make the alias available outside of the module" {
                Import-MqcnAlias -Alias "ab" -Command "Microsoft.PowerShell.Management\Get-Item"
                Get-Alias -Name "ab" -Scope "Global" -ErrorAction Ignore | Should BeNullOrEmpty
                Get-Alias -Name "ab" -Scope "Script" -ErrorAction Ignore | Should BeNullOrEmpty
            }
        }
    }
}
