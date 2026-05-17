#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

<#
.SYNOPSIS
    Unit test template for AtlassianPS.Configuration public functions.

.DESCRIPTION
    Copy this file and rename it to:

        <FunctionName>.Unit.Tests.ps1

    This template captures the current test-harness pattern used in this module:
    runtime setup in BeforeAll, no module import in BeforeDiscovery, and tests
    executed inside InModuleScope.
#>

Describe "%FUNCTION-NAME%" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        # $VerbosePreference = "Continue"  # Optional mock debug output

        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        BeforeEach {
            #region Mocking
            # Example:
            # Mock Write-DebugMessage -ModuleName "AtlassianPS.Configuration" {}
            # Mock Write-Verbose -ModuleName "AtlassianPS.Configuration" {}
            #endregion Mocking
        }

        Context "Sanity checking" {
            BeforeAll {
                $script:command = Get-Command -Name "%FUNCTION-NAME%"
            }

            It "has a parameter '<ParameterName>' of type '<Type>'" -TestCases @(
                @{ ParameterName = "%PARAMETER%"; Type = [String] }
            ) {
                $command | Should -HaveParameter $ParameterName -Type $Type
            }
        }

        Context "Behavior checking" {
            BeforeEach {
                #region Arrange
                # Example:
                # $script:Configuration = @{
                #     Foo = "lorem ipsum"
                #     Bar = 42
                # }
                #endregion Arrange
            }

            It "handles the primary success path" {
                # Arrange
                # Act
                # Assert
                { %FUNCTION-NAME% } | Should -Not -Throw
            }
        }
    }
}
