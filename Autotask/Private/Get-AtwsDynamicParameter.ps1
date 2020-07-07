
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsDynamicParameter {
  <#
        .SYNOPSIS
            This function creates a Powershell dynamic parameter definition as a runtime defined parameter.
        .DESCRIPTION
            Based on parameter values this function creates a runtime defined parameter that can be converted to a scriptblock and executed.
        .INPUTS
            Multiple parameters representing the various parameter options.
        .OUTPUTS
            System.Management.Automation.RuntimeDefinedParameter
        .EXAMPLE
            Get-AtwsDynamicParameter -Name 'Filter' -SetName 'Filter' -Type 'string' -Mandatory -Remaining -NotNull  -Array -Comment $Comment
        .NOTES
            NAME: Get-AtwsPSDynamicParameter
        .LINK

  #>
  [CmdLetBinding()]
  [Outputtype([System.Management.Automation.RuntimeDefinedParameter])]
  Param
  (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string[]]$Alias,
    
    [Parameter(Mandatory = $true)]
    [string]$type,
    
    [switch]$Mandatory,

    [Alias('Remaining')]
    [switch]$ValueFromRemainingArguments,

    [Alias('setName')]
    [string[]]$ParametersetName,

    [Alias('Pipeline')]
    [switch]$valueFromPipeline,

    [Alias('NotNull')]
    [switch]$ValidateNotNullOrEmpty,

    [string[]]$ValidateSet,

    [Alias('Length')]
    [int]$ValidateLength,

    [string]$Comment,

    [switch]$Array,
        
    [switch]$nullable


          
  )
  
  begin { 
    Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
    $paramProperties = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

  }

  process { 
    # NB: $Comment is ignored for now
    foreach ($setName in $parametersetName) { 

      $property = New-Object System.Management.Automation.ParameterAttribute
        
      # Hardcoded filter against requiring parameters for 'Input_Object'
      if ($Mandatory.IsPresent -and $setName -in 'By_parameters', 'Filter') {
        $property.Mandatory = $true
      }
      $property.ParameterSetName = $setName
      $property.ValueFromRemainingArguments = $valueFromRemainingArguments.IsPresent
      $property.ValueFromPipeline = $valueFromPipeline.IsPresent
      $paramProperties += $property
    }
    # Add any aliases
    if ($Alias.Count -gt 0) {
      $paramProperties += New-Object System.Management.Automation.AliasAttribute($Alias)
    }
    # Add validate not null if present
    if ($ValidateNotNullOrEmpty.IsPresent) {
      $paramProperties += New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute($true)
    }

    # Add validate length if present
    if ($ValidateLength -gt 0) {
      $validateSetProperty = New-Object System.Management.Automation.ValidateLengthAttribute
      $validateSetProperty.MinLength = 0
      $validateSetProperty.MaxLength = $ValidateLength
      $paramProperties += $validateSetProperty
    }
        New-Object System.Management.Automation.ParameterMetadata
    # Add Validateset if present
    if ($ValidateSet.Count -gt 0) { 
      $paramProperties += New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)
    }

    # Add the correct variable type for the parameter
    $type = switch ($type) {
      'Integer' {
        'Int'
      }
      'Short' {
        'Int16'
      }
      default {
        $type
      }
    }
    if ($nullable.IsPresent) {
      $type = "Nullable[$type]"
    }

    if ($Array.IsPresent) {
      $type += '[]'
    }
    
    $parameter = New-Object System.Management.Automation.RuntimeDefinedParameter($Name, [system.type]$type, $paramProperties)
  }

  end { 
    Return $parameter
  }
}
