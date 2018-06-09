#requires -modules Pester

Describe "Validation of example codes in the documentation" -Tag Documentation {

    BeforeAll {
        Import-Module BuildHelpers
        Remove-Item -Path Env:\BH*
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path "$PSScriptRoot\.." -ErrorAction SilentlyContinue
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Import-Module $env:BHPSModuleManifest
    }
    AfterAll {
        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    $isBuild = (Get-Module $env:BHProjectName).ModuleBase -like "*/Release/$env:BHProjectName"
    $assertSplat = @{
        conditionToCheck = $isBuild
        failureMessage   = "Examples can only be tested in the build environment. Please run `Invoke-Build -Task Build`."
    }
    Assert @assertSplat

    $functions = Get-Command -Module $env:BHProjectName | Get-Help
    foreach ($function in $functions) {
        Context "Examples of $($function.Name)" {


        }
    }
}
