
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsDynamicParameterDefinition {
    <#
        .SYNOPSIS
            This function returns a complete parameter set for a given entity and verb.
        .DESCRIPTION
            This function takes an entity as EntityInfo, an array of FieldInfo and a verb.
            It creates a set of default parameters and then loops through all fields in
            FieldInfo and adds them as parameters with validation sets for picklists, 
            correct type and help texts.
        .INPUTS
            Autotask.EntityInfo
            Autotask.FieldInfo[]
            String, validateset get, set, new, remove
        .OUTPUTS
            System.Management.Automation.RuntimeDefinedParameterDictionary
        .EXAMPLE
            Get-AtwsParameterDefinition -Entity $EntityInfo -FieldInfo $FieldInfo -Verb Get

        .NOTES
            NAME: Get-AtwsParameterDefinition
        .LINK
            $parameters += Get-AtwsDynamicParameter
  #>
    [CmdLetBinding()]
    [Outputtype([System.Management.Automation.RuntimeDefinedParameterDictionary])]

    Param
    (   
        [Parameter(Mandatory)]
        [PSObject]
        $Entity,
        
        [Parameter(Mandatory)]
        [ValidateSet('Get', 'Set', 'New', 'Remove')]
        [string]
        $Verb,
        
        [Parameter(Mandatory)]
        [Autotask.Field[]]
        $FieldInfo
    )
    
    begin {

        Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
        
        $Mandatory = @{ }
        $parameterSet = @{ }
    
        # Add Default PSParameter info to Fields
        foreach ($field in $fieldInfo) {
            # We need to overwrite this based on verb. No field is required in a Get, for instance.
            $Mandatory[$field.Name] = $field.IsRequired
            $parameterSet[$field.Name] = @('By_parameters')
        }

    }

    process { 
  
        switch ($Verb) {
            'Get' { 
                [array]$fields = $fieldInfo.Where{ $_.IsQueryable -and $_.IsPickList } | ForEach-Object {
                    $Mandatory[$_.Name] = $false
                    $_
                }
            }
            'Set' { 
                [array]$fields = $fieldInfo.Where{ -Not $_.IsReadOnly -and $_.IsPickList } | ForEach-Object {
                    $parameterSet[$_.Name] = @('Input_Object', 'By_parameters', 'By_Id')
                    $_
                }
            }
            'New' {
                [array]$fields = $fieldInfo.Where{ $_.Name -ne 'Id' -and $_.IsPickList }
            }
            default {
                return
            }

        }

        # A container for the runtime parameters
        $runtimeParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    
        foreach ($field in $fields) {
            # NB: $Comment is ignored for now

            # A container to hold the parameter attributes
            $paramProperties = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create a [parameter()] clause per parameterset
            foreach ($setName in $parameterSet[$field.Name]) { 

                $property = New-Object System.Management.Automation.ParameterAttribute
                $property.Mandatory = $Mandatory[$field.Name]
                $property.ParameterSetName = $setName
                $property.ValueFromRemainingArguments = $valueFromRemainingArguments.IsPresent
                $property.ValueFromPipeline = $valueFromPipeline.IsPresent
                $paramProperties.Add($property)
            }
            # Add validate not null if field is required
            if ($field.IsRequired) {
                $property = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute
                $paramProperties.Add($property)
            }
        
            # Add Validateset if present
            if ($field.PickListValues.Count -gt 0) { 
                $ValidateSet = $field.PickListValues | Where-Object { $_.IsActive } | Select-Object -ExpandProperty Label | Sort-Object -Unique
                $property = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)
                $paramProperties.Add($property)
            }
            
            # Allow multiple values for Get functions
            $type = 'string'
            if ($Verb -eq 'Get') {
                $type += '[]'
            }
            
            # Create a new parameter with all attributes
            $parameter = New-Object System.Management.Automation.RuntimeDefinedParameter($field.Name, [system.type]$type, $paramProperties)

            # Add parameter to runtime parameters
            $runtimeParameters.Add($parameter.Name, $parameter)
        }
    }

    end {
        if ($runtimeParameters.count -gt 0) { 
            return $runtimeParameters
        }
    }
}
