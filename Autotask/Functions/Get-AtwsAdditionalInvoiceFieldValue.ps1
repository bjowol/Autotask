#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsAdditionalInvoiceFieldValue
{


<#
.SYNOPSIS
This function get one or more AdditionalInvoiceFieldValue through the Autotask Web Services API.
.DESCRIPTION
This function creates a query based on any parameters you give and returns any resulting objects from the Autotask Web Services Api. By default the function returns any objects with properties that are Equal (-eq) to the value of the parameter. To give you more flexibility you can modify the operator by using -NotEquals [ParameterName[]], -LessThan [ParameterName[]] and so on.

Possible operators for all parameters are:
 -NotEquals
 -GreaterThan
 -GreaterThanOrEqual
 -LessThan
 -LessThanOrEquals 

Additional operators for [string] parameters are:
 -Like (supports * or % as wildcards)
 -NotLike
 -BeginsWith
 -EndsWith
 -Contains

Properties with picklists are:
AdditionalInvoiceFieldID

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.AdditionalInvoiceFieldValue[]]. This function outputs the Autotask.AdditionalInvoiceFieldValue that was returned by the API.
.EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldValueName SomeName
Returns the object with AdditionalInvoiceFieldValueName 'SomeName', if any.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldValueName 'Some Name'
Returns the object with AdditionalInvoiceFieldValueName 'Some Name', if any.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldValueName 'Some Name' -NotEquals AdditionalInvoiceFieldValueName
Returns any objects with a AdditionalInvoiceFieldValueName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldValueName SomeName* -Like AdditionalInvoiceFieldValueName
Returns any object with a AdditionalInvoiceFieldValueName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldValueName SomeName* -NotLike AdditionalInvoiceFieldValueName
Returns any object with a AdditionalInvoiceFieldValueName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldID <PickList Label>
Returns any AdditionalInvoiceFieldValues with property AdditionalInvoiceFieldID equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldID <PickList Label> -NotEquals AdditionalInvoiceFieldID 
Returns any AdditionalInvoiceFieldValues with property AdditionalInvoiceFieldID NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldID <PickList Label1>, <PickList Label2>
Returns any AdditionalInvoiceFieldValues with property AdditionalInvoiceFieldID equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -AdditionalInvoiceFieldID <PickList Label1>, <PickList Label2> -NotEquals AdditionalInvoiceFieldID
Returns any AdditionalInvoiceFieldValues with property AdditionalInvoiceFieldID NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsAdditionalInvoiceFieldValue -Id 1234 -AdditionalInvoiceFieldValueName SomeName* -AdditionalInvoiceFieldID <PickList Label1>, <PickList Label2> -Like AdditionalInvoiceFieldValueName -NotEquals AdditionalInvoiceFieldID -GreaterThan Id
An example of a more complex query. This command returns any AdditionalInvoiceFieldValues with Id GREATER THAN 1234, a AdditionalInvoiceFieldValueName that matches the simple pattern SomeName* AND that has a AdditionalInvoiceFieldID that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.


#>

  [CmdLetBinding(SupportsShouldProcess = $true, DefaultParameterSetName='Filter', ConfirmImpact='None')]
  Param
  (
# A filter that limits the number of objects that is returned from the API
    [Parameter(
      Mandatory = $true,
      ValueFromRemainingArguments = $true,
      ParametersetName = 'Filter'
    )]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Filter,

# Follow this external ID and return any external objects
    [Parameter(
      ParametersetName = 'Filter'
    )]
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Alias('GetRef')]
    [ValidateNotNullOrEmpty()]
    [string]
    $GetReferenceEntityById,

# Return entities of selected type that are referencing to this entity.
    [Parameter(
      ParametersetName = 'Filter'
    )]
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Alias('External')]
    [ValidateNotNullOrEmpty()]
    [string]
    $GetExternalEntityByThisEntityId,

# Return all objects in one query
    [Parameter(
      ParametersetName = 'Get_all'
    )]
    [switch]
    $All,

# Additional Invoice Field ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity AdditionalInvoiceFieldValue -FieldName AdditionalInvoiceFieldID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity AdditionalInvoiceFieldValue -FieldName AdditionalInvoiceFieldID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $AdditionalInvoiceFieldID,

# Field Value
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,100)]
    [string[]]
    $FieldValue,

# Additional Invoice Field Value ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Batch ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $InvoiceBatchID,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('AdditionalInvoiceFieldID', 'id', 'FieldValue', 'InvoiceBatchID')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('AdditionalInvoiceFieldID', 'id', 'FieldValue', 'InvoiceBatchID')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('AdditionalInvoiceFieldID', 'id', 'FieldValue', 'InvoiceBatchID')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AdditionalInvoiceFieldID', 'InvoiceBatchID', 'FieldValue')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AdditionalInvoiceFieldID', 'InvoiceBatchID', 'FieldValue')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AdditionalInvoiceFieldID', 'InvoiceBatchID', 'FieldValue')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AdditionalInvoiceFieldID', 'InvoiceBatchID', 'FieldValue')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('FieldValue')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('FieldValue')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('FieldValue')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('FieldValue')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('FieldValue')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'AdditionalInvoiceFieldValue'
    
        # Enable modern -Debug behavior
        if ($PSCmdlet.MyInvocation.BoundParameters['Debug'].IsPresent) {
            $DebugPreference = 'Continue' 
        }
        else {
            # Respect configured preference
            $DebugPreference = $Script:Atws.Configuration.DebugPref
        }
    
        Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)

        if (!($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)) {
            # No local override of central preference. Load central preference
            $VerbosePreference = $Script:Atws.Configuration.VerbosePref
        }
    
    }


    process {
        # Parameterset Get_All has a single parameter: -All
        # Set the Filter manually to get every single object of this type 
        if ($PSCmdlet.ParameterSetName -eq 'Get_all') { 
            $Filter = @('id', '-ge', 0)
        }
        # So it is not -All. If Filter does not exist it has to be By_parameters
        elseif (-not ($Filter)) {
    
            Write-Debug ('{0}: Query based on parameters, parsing' -F $MyInvocation.MyCommand.Name)
      
            # Convert named parameters to a filter definition that can be parsed to QueryXML
            [string[]]$Filter = ConvertTo-AtwsFilter -BoundParameters $PSBoundParameters -EntityName $entityName
        }
        # Not parameters, nor Get_all. There are only three parameter sets, so now we know
        # that we were passed a Filter
        else {
      
            Write-Debug ('{0}: Query based on manual filter, parsing' -F $MyInvocation.MyCommand.Name)
            
            # Parse the filter string and expand variables in _this_ scope (dot-sourcing)
            # or the variables will not be available and expansion will fail
            $Filter = . Update-AtwsFilter -Filterstring $Filter
        } 

        # Prepare shouldProcess comments
        $caption = $MyInvocation.MyCommand.Name
        $verboseDescription = '{0}: About to query the Autotask Web API for {1}(s).' -F $caption, $entityName
        $verboseWarning = '{0}: About to query the Autotask Web API for {1}(s). Do you want to continue?' -F $caption, $entityName
    
        # Lets do it and say we didn't!
        if ($PSCmdlet.ShouldProcess($verboseDescription, $verboseWarning, $caption)) { 
    
            # Make the query and pass the optional parameters to Get-AtwsData
            $result = Get-AtwsData -Entity $entityName -Filter $Filter `
                -NoPickListLabel:$NoPickListLabel.IsPresent `
                -GetReferenceEntityById $GetReferenceEntityById `
                -GetExternalEntityByThisEntityId $GetExternalEntityByThisEntityId
    
            Write-Verbose ('{0}: Number of entities returned by base query: {1}' -F $MyInvocation.MyCommand.Name, $result.Count)

        }
    }

    end {
        Write-Debug ('{0}: End of function' -F $MyInvocation.MyCommand.Name)
        if ($result) {
            Return $result
        }
    }


}
