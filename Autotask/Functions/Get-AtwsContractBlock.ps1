#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsContractBlock
{


<#
.SYNOPSIS
This function get one or more ContractBlock through the Autotask Web Services API.
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
Status
IsPaid
PaymentType

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.ContractBlock[]]. This function outputs the Autotask.ContractBlock that was returned by the API.
.EXAMPLE
Get-AtwsContractBlock -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsContractBlock -ContractBlockName SomeName
Returns the object with ContractBlockName 'SomeName', if any.
 .EXAMPLE
Get-AtwsContractBlock -ContractBlockName 'Some Name'
Returns the object with ContractBlockName 'Some Name', if any.
 .EXAMPLE
Get-AtwsContractBlock -ContractBlockName 'Some Name' -NotEquals ContractBlockName
Returns any objects with a ContractBlockName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsContractBlock -ContractBlockName SomeName* -Like ContractBlockName
Returns any object with a ContractBlockName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsContractBlock -ContractBlockName SomeName* -NotLike ContractBlockName
Returns any object with a ContractBlockName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsContractBlock -Status <PickList Label>
Returns any ContractBlocks with property Status equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsContractBlock -Status <PickList Label> -NotEquals Status 
Returns any ContractBlocks with property Status NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsContractBlock -Status <PickList Label1>, <PickList Label2>
Returns any ContractBlocks with property Status equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsContractBlock -Status <PickList Label1>, <PickList Label2> -NotEquals Status
Returns any ContractBlocks with property Status NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsContractBlock -Id 1234 -ContractBlockName SomeName* -Status <PickList Label1>, <PickList Label2> -Like ContractBlockName -NotEquals Status -GreaterThan Id
An example of a more complex query. This command returns any ContractBlocks with Id GREATER THAN 1234, a ContractBlockName that matches the simple pattern SomeName* AND that has a Status that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-AtwsContractBlock
 .LINK
Set-AtwsContractBlock

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
    [ValidateSet('ContractID')]
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

# Contract ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[Int][]]
    $ContractID,

# DatePurchased
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[datetime][]]
    $DatePurchased,

# EndDate
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[datetime][]]
    $EndDate,

# Rate
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[double][]]
    $HourlyRate,

# Hours
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[double][]]
    $Hours,

# id
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# InvoiceNumber
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $InvoiceNumber,

# Paid
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity ContractBlock -FieldName IsPaid -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity ContractBlock -FieldName IsPaid -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $IsPaid,

# PaymentNumber
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $PaymentNumber,

# paymentID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity ContractBlock -FieldName PaymentType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity ContractBlock -FieldName PaymentType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $PaymentType,

# StartDate
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[datetime][]]
    $StartDate,

# Status
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity ContractBlock -FieldName Status -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity ContractBlock -FieldName Status -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $Status,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('DatePurchased', 'IsPaid', 'Status', 'StartDate', 'PaymentType', 'PaymentNumber', 'ContractID', 'EndDate', 'Hours', 'id', 'HoursApproved', 'InvoiceNumber', 'HourlyRate')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('DatePurchased', 'IsPaid', 'Status', 'StartDate', 'PaymentType', 'PaymentNumber', 'ContractID', 'EndDate', 'Hours', 'id', 'HoursApproved', 'InvoiceNumber', 'HourlyRate')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('DatePurchased', 'IsPaid', 'Status', 'StartDate', 'PaymentType', 'PaymentNumber', 'ContractID', 'EndDate', 'Hours', 'id', 'HoursApproved', 'InvoiceNumber', 'HourlyRate')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ContractID', 'Status', 'IsPaid', 'DatePurchased', 'StartDate', 'EndDate', 'Hours', 'HourlyRate', 'InvoiceNumber', 'PaymentNumber', 'PaymentType', 'HoursApproved')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ContractID', 'Status', 'IsPaid', 'DatePurchased', 'StartDate', 'EndDate', 'Hours', 'HourlyRate', 'InvoiceNumber', 'PaymentNumber', 'PaymentType', 'HoursApproved')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ContractID', 'Status', 'IsPaid', 'DatePurchased', 'StartDate', 'EndDate', 'Hours', 'HourlyRate', 'InvoiceNumber', 'PaymentNumber', 'PaymentType', 'HoursApproved')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ContractID', 'Status', 'IsPaid', 'DatePurchased', 'StartDate', 'EndDate', 'Hours', 'HourlyRate', 'InvoiceNumber', 'PaymentNumber', 'PaymentType', 'HoursApproved')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('IsPaid', 'InvoiceNumber', 'PaymentNumber')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('IsPaid', 'InvoiceNumber', 'PaymentNumber')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('IsPaid', 'InvoiceNumber', 'PaymentNumber')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('IsPaid', 'InvoiceNumber', 'PaymentNumber')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('IsPaid', 'InvoiceNumber', 'PaymentNumber')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('DatePurchased', 'StartDate', 'EndDate')]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'ContractBlock'
    
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
