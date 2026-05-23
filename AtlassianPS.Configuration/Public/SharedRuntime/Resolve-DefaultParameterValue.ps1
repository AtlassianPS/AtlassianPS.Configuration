function Resolve-DefaultParameterValue {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [Parameter(Mandatory)]
        [Hashtable]
        $Reference,

        [Parameter(Mandatory)]
        [String[]]
        $CommandName,

        [Parameter()]
        [Hashtable]
        $Target = @{},

        [Parameter()]
        [String[]]
        $ParameterName = '*'
    )

    begin {
        $defaultItems = New-Object -TypeName System.Collections.ArrayList

        foreach ($key in $Reference.Keys) {
            $null = $defaultItems.Add(
                [PSCustomObject]@{
                    Key       = $key
                    Value     = $Reference[$key]
                    Command   = $key.Split(':')[0]
                    Parameter = $key.Split(':')[1]
                }
            )
        }
    }

    process {
        foreach ($command in $CommandName) {
            foreach ($item in $defaultItems) {
                if ($command -notlike $item.Command) {
                    continue
                }

                foreach ($parameter in $ParameterName) {
                    if ($item.Parameter -like $parameter) {
                        if ($parameter -ne '*') {
                            $Target["${command}:$parameter"] = $item.Value
                        }
                        else {
                            $Target["${command}:$($item.Parameter)"] = $item.Value
                        }
                    }
                }
            }
        }
    }

    end {
        $Target
    }
}
