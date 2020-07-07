
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
            $Mandatory[$field.Name] = $field.IsRequired
            $parameterSet[$field.Name] = @('By_parameters')
        }

        # Create the runtime parameter dictionary
        $parameters = @()
    }

    process { 
  
        switch ($Verb) {
            'Get' { 
                [array]$fields = $fieldInfo.Where{ $_.IsQueryable } | ForEach-Object {
                    $Mandatory[$_.Name] = $false
                    $_
                }
            }
            'Set' { 
                [array]$fields = $fieldInfo.Where{ -Not $_.IsReadOnly } | ForEach-Object {
                    $parameterSet[$_.Name] = @('Input_Object', 'By_parameters', 'By_Id')
                    $_
                }
            }
            'New' {
                [array]$fields = $fieldInfo.Where{
                    $_.Name -ne 'Id'
                }
            }
            default {
                return
            }

        }
    
        foreach ($field in $fields.where($_.IsPickList) ) {
            # Fieldtype for picklists
            $Type = 'string'
            $ValidateLength = 0
            $Alias = @() 
            $parameterOptions = @{
                Mandatory              = $Mandatory[$field.Name]
                ParameterSetName       = $parameterSet[$field.Name]
                ValidateNotNullOrEmpty = $field.IsRequired
                ValidateLength         = $ValidateLength
                ValidateSet            = $field.PickListValues | Where-Object { $_.IsActive } | Select-Object -ExpandProperty Label | Sort-Object -Unique
                Array                  = $(($Verb -eq 'Get'))
                Name                   = $field.Name
                Alias                  = $Alias
                Type                   = $Type
                Comment                = $field.Label
                Nullable               = $false
            }

            $parameters += Get-AtwsDynamicParameter @ParameterOptions
        }
    
    
        # Make modifying operators possible
        if ($Verb -eq 'Get') {
            # These operators work for all fields (add quote characters here)
            [array]$Labels = $fields | Select-Object -ExpandProperty Name
            if ($Entity.HasUserDefinedFields) { $Labels += 'UserDefinedField' }
            foreach ($Operator in 'NotEquals', 'IsNull', 'IsNotNull') {
                $parameters += Get-AtwsDynamicParameter -Name $Operator -SetName 'By_parameters' -Type 'string' -Array -ValidateSet $Labels
            }

            # These operators work for all fields except boolean (add quote characters here)
            [array]$Labels = $fields | Where-Object { $_.Type -ne 'boolean' } | Select-Object -ExpandProperty Name
            if ($Entity.HasUserDefinedFields) { $Labels += 'UserDefinedField' }
            foreach ($Operator in 'GreaterThan', 'GreaterThanOrEquals', 'LessThan', 'LessThanOrEquals') {
                $parameters += Get-AtwsDynamicParameter -Name $Operator -SetName 'By_parameters' -Type 'string' -Array -ValidateSet $Labels
            }

            # These operators only work for strings (add quote characters here)
            [array]$Labels = $fields | Where-Object { $_.Type -eq 'string' } | Select-Object -ExpandProperty Name
            if ($Entity.HasUserDefinedFields) { $Labels += 'UserDefinedField' }
            foreach ($Operator in 'Like', 'NotLike', 'BeginsWith', 'EndsWith', 'Contains') {
                $parameters += Get-AtwsDynamicParameter -Name $Operator -SetName 'By_parameters' -Type 'string' -Array -ValidateSet $Labels
            }
      
            # This operator only work for datetime (add quote characters here)
            [array]$Labels = $fields | Where-Object { $_.Type -eq 'datetime' } | Select-Object -ExpandProperty Name
            if ($Entity.HasUserDefinedFields) { $Labels += 'UserDefinedField' }
            foreach ($Operator in 'IsThisDay') {
                $parameters += Get-AtwsDynamicParameter -Name $Operator -SetName 'By_parameters' -Type 'string' -Array -ValidateSet $Labels
            }
        }
    }

    end {
        if($parameters.count -gt 0) { 
            $runtimeParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            foreach ($p in $parameters) {
                $runtimeParameters.Add($p.Name, $p)
            }

            return $runtimeParameters
        }
    }
}
