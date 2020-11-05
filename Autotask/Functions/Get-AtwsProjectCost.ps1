#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsProjectCost
{


<#
.SYNOPSIS
This function get one or more ProjectCost through the Autotask Web Services API.
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
CostType
Status

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.ProjectCost[]]. This function outputs the Autotask.ProjectCost that was returned by the API.
.EXAMPLE
Get-AtwsProjectCost -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsProjectCost -ProjectCostName SomeName
Returns the object with ProjectCostName 'SomeName', if any.
 .EXAMPLE
Get-AtwsProjectCost -ProjectCostName 'Some Name'
Returns the object with ProjectCostName 'Some Name', if any.
 .EXAMPLE
Get-AtwsProjectCost -ProjectCostName 'Some Name' -NotEquals ProjectCostName
Returns any objects with a ProjectCostName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsProjectCost -ProjectCostName SomeName* -Like ProjectCostName
Returns any object with a ProjectCostName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsProjectCost -ProjectCostName SomeName* -NotLike ProjectCostName
Returns any object with a ProjectCostName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsProjectCost -CostType <PickList Label>
Returns any ProjectCosts with property CostType equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsProjectCost -CostType <PickList Label> -NotEquals CostType 
Returns any ProjectCosts with property CostType NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsProjectCost -CostType <PickList Label1>, <PickList Label2>
Returns any ProjectCosts with property CostType equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsProjectCost -CostType <PickList Label1>, <PickList Label2> -NotEquals CostType
Returns any ProjectCosts with property CostType NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsProjectCost -Id 1234 -ProjectCostName SomeName* -CostType <PickList Label1>, <PickList Label2> -Like ProjectCostName -NotEquals CostType -GreaterThan Id
An example of a more complex query. This command returns any ProjectCosts with Id GREATER THAN 1234, a ProjectCostName that matches the simple pattern SomeName* AND that has a CostType that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-AtwsProjectCost
 .LINK
Remove-AtwsProjectCost
 .LINK
Set-AtwsProjectCost

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
    [ValidateSet('ProductID', 'AllocationCodeID', 'CreatorResourceID', 'BusinessDivisionSubdivisionID', 'ProjectID', 'ContractServiceBundleID', 'ContractServiceID')]
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
    [ValidateSet('BillingItem')]
    [string]
    $GetExternalEntityByThisEntityId,

# Return all objects in one query
    [Parameter(
      ParametersetName = 'Get_all'
    )]
    [switch]
    $All,

# Allocation Code
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $AllocationCodeID,

# Billable Amount
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $BillableAmount,

# Billable To Account
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $BillableToAccount,

# Billed
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $Billed,

# Business Division Subdivision ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $BusinessDivisionSubdivisionID,

# Contract Service Bundle ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $ContractServiceBundleID,

# Contract Service ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $ContractServiceID,

# Cost Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity ProjectCost -FieldName CostType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity ProjectCost -FieldName CostType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $CostType,

# Create Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $CreateDate,

# Created By
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $CreatorResourceID,

# Date Purchased
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[datetime][]]
    $DatePurchased,

# Description
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,2000)]
    [string[]]
    $Description,

# Estimated Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $EstimatedCost,

# Extended Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $ExtendedCost,

# id
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Internal Currency Billable Amount
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $InternalCurrencyBillableAmount,

# Internal Currency Unit Price
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $InternalCurrencyUnitPrice,

# Internal Purchase Order Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $InternalPurchaseOrderNumber,

# Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,100)]
    [string[]]
    $Name,

# Notes
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,2000)]
    [string[]]
    $Notes,

# Product
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $ProductID,

# Project
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $ProjectID,

# Purchase Order Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $PurchaseOrderNumber,

# Status
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity ProjectCost -FieldName Status -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity ProjectCost -FieldName Status -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $Status,

# Last Modified By
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $StatusLastModifiedBy,

# Last Modified Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $StatusLastModifiedDate,

# Unit Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $UnitCost,

# Unit Price
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $UnitPrice,

# Unit Quantity
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[double][]]
    $UnitQuantity,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('PurchaseOrderNumber', 'DatePurchased', 'Billed', 'StatusLastModifiedDate', 'InternalPurchaseOrderNumber', 'UnitQuantity', 'InternalCurrencyUnitPrice', 'CreatorResourceID', 'Name', 'Notes', 'ExtendedCost', 'ContractServiceBundleID', 'UnitCost', 'CostType', 'BusinessDivisionSubdivisionID', 'id', 'ProjectID', 'UnitPrice', 'BillableAmount', 'ContractServiceID', 'CreateDate', 'Description', 'InternalCurrencyBillableAmount', 'AllocationCodeID', 'BillableToAccount', 'EstimatedCost', 'Status', 'StatusLastModifiedBy', 'ProductID')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('PurchaseOrderNumber', 'DatePurchased', 'Billed', 'StatusLastModifiedDate', 'InternalPurchaseOrderNumber', 'UnitQuantity', 'InternalCurrencyUnitPrice', 'CreatorResourceID', 'Name', 'Notes', 'ExtendedCost', 'ContractServiceBundleID', 'UnitCost', 'CostType', 'BusinessDivisionSubdivisionID', 'id', 'ProjectID', 'UnitPrice', 'BillableAmount', 'ContractServiceID', 'CreateDate', 'Description', 'InternalCurrencyBillableAmount', 'AllocationCodeID', 'BillableToAccount', 'EstimatedCost', 'Status', 'StatusLastModifiedBy', 'ProductID')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('PurchaseOrderNumber', 'DatePurchased', 'Billed', 'StatusLastModifiedDate', 'InternalPurchaseOrderNumber', 'UnitQuantity', 'InternalCurrencyUnitPrice', 'CreatorResourceID', 'Name', 'Notes', 'ExtendedCost', 'ContractServiceBundleID', 'UnitCost', 'CostType', 'BusinessDivisionSubdivisionID', 'id', 'ProjectID', 'UnitPrice', 'BillableAmount', 'ContractServiceID', 'CreateDate', 'Description', 'InternalCurrencyBillableAmount', 'AllocationCodeID', 'BillableToAccount', 'EstimatedCost', 'Status', 'StatusLastModifiedBy', 'ProductID')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProjectID', 'ProductID', 'AllocationCodeID', 'Name', 'Description', 'DatePurchased', 'CostType', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'UnitQuantity', 'UnitCost', 'UnitPrice', 'ExtendedCost', 'EstimatedCost', 'BillableAmount', 'Status', 'StatusLastModifiedBy', 'StatusLastModifiedDate', 'CreateDate', 'CreatorResourceID', 'ContractServiceID', 'ContractServiceBundleID', 'InternalCurrencyBillableAmount', 'InternalCurrencyUnitPrice', 'BusinessDivisionSubdivisionID', 'Notes')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProjectID', 'ProductID', 'AllocationCodeID', 'Name', 'Description', 'DatePurchased', 'CostType', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'UnitQuantity', 'UnitCost', 'UnitPrice', 'ExtendedCost', 'EstimatedCost', 'BillableAmount', 'Status', 'StatusLastModifiedBy', 'StatusLastModifiedDate', 'CreateDate', 'CreatorResourceID', 'ContractServiceID', 'ContractServiceBundleID', 'InternalCurrencyBillableAmount', 'InternalCurrencyUnitPrice', 'BusinessDivisionSubdivisionID', 'Notes')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProjectID', 'ProductID', 'AllocationCodeID', 'Name', 'Description', 'DatePurchased', 'CostType', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'UnitQuantity', 'UnitCost', 'UnitPrice', 'ExtendedCost', 'EstimatedCost', 'BillableAmount', 'Status', 'StatusLastModifiedBy', 'StatusLastModifiedDate', 'CreateDate', 'CreatorResourceID', 'ContractServiceID', 'ContractServiceBundleID', 'InternalCurrencyBillableAmount', 'InternalCurrencyUnitPrice', 'BusinessDivisionSubdivisionID', 'Notes')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProjectID', 'ProductID', 'AllocationCodeID', 'Name', 'Description', 'DatePurchased', 'CostType', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'UnitQuantity', 'UnitCost', 'UnitPrice', 'ExtendedCost', 'EstimatedCost', 'BillableAmount', 'Status', 'StatusLastModifiedBy', 'StatusLastModifiedDate', 'CreateDate', 'CreatorResourceID', 'ContractServiceID', 'ContractServiceBundleID', 'InternalCurrencyBillableAmount', 'InternalCurrencyUnitPrice', 'BusinessDivisionSubdivisionID', 'Notes')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'Notes')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'Notes')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'Notes')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'Notes')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'PurchaseOrderNumber', 'InternalPurchaseOrderNumber', 'Notes')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('DatePurchased', 'StatusLastModifiedDate', 'CreateDate')]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'ProjectCost'
    
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
