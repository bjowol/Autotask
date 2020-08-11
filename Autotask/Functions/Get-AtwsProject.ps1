#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsProject
{


<#
.SYNOPSIS
This function get one or more Project through the Autotask Web Services API.
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
Type
Status
Department
LineOfBusiness

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.Project[]]. This function outputs the Autotask.Project that was returned by the API.
.EXAMPLE
Get-AtwsProject -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsProject -ProjectName SomeName
Returns the object with ProjectName 'SomeName', if any.
 .EXAMPLE
Get-AtwsProject -ProjectName 'Some Name'
Returns the object with ProjectName 'Some Name', if any.
 .EXAMPLE
Get-AtwsProject -ProjectName 'Some Name' -NotEquals ProjectName
Returns any objects with a ProjectName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsProject -ProjectName SomeName* -Like ProjectName
Returns any object with a ProjectName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsProject -ProjectName SomeName* -NotLike ProjectName
Returns any object with a ProjectName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsProject -Type <PickList Label>
Returns any Projects with property Type equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsProject -Type <PickList Label> -NotEquals Type 
Returns any Projects with property Type NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsProject -Type <PickList Label1>, <PickList Label2>
Returns any Projects with property Type equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsProject -Type <PickList Label1>, <PickList Label2> -NotEquals Type
Returns any Projects with property Type NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsProject -Id 1234 -ProjectName SomeName* -Type <PickList Label1>, <PickList Label2> -Like ProjectName -NotEquals Type -GreaterThan Id
An example of a more complex query. This command returns any Projects with Id GREATER THAN 1234, a ProjectName that matches the simple pattern SomeName* AND that has a Type that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-AtwsProject
 .LINK
Set-AtwsProject

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
    [ValidateSet('ContractID', 'BusinessDivisionSubdivisionID', 'ImpersonatorCreatorResourceID', 'AccountID')]
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
    [ValidateSet('PurchaseOrderItem', 'Phase', 'ProjectCost', 'ProjectNote', 'Ticket', 'BillingItem', 'NotificationHistory', 'Task', 'ExpenseItem', 'Quote')]
    [string]
    $GetExternalEntityByThisEntityId,

# Return all objects in one query
    [Parameter(
      ParametersetName = 'Get_all'
    )]
    [switch]
    $All,

# id
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Project Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Alias('Name')]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,100)]
    [string[]]
    $ProjectName,

# Account ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[Int][]]
    $AccountID,

# Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Project -FieldName Type -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Project -FieldName Type -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $Type,

# Ext Project Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $ExtPNumber,

# Project Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $ProjectNumber,

# Description
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,2000)]
    [string[]]
    $Description,

# Created DateTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $CreateDateTime,

# Created By
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $CreatorResourceID,

# Start Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[datetime][]]
    $StartDateTime,

# End Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[datetime][]]
    $EndDateTime,

# Duration
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $Duration,

# Actual Hours
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $ActualHours,

# Actual Billed Hours
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $ActualBilledHours,

# Estimated Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $EstimatedTime,

# Labor Estimated Revenue
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $LaborEstimatedRevenue,

# Labor Estimated Costs
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $LaborEstimatedCosts,

# Labor Estimated Margin Percentage
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $LaborEstimatedMarginPercentage,

# Project Cost Revenue
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $ProjectCostsRevenue,

# Project Estimated costs
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $ProjectCostsBudget,

# Project Cost Estimated Margin Percentage
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $ProjectCostEstimatedMarginPercentage,

# Change Orders Revenue
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $ChangeOrdersRevenue,

# SG&A
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $SGDA,

# Original Estimated Revenue
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $OriginalEstimatedRevenue,

# Estimated Sales Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $EstimatedSalesCost,

# Status
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Project -FieldName Status -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Project -FieldName Status -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $Status,

# Contract
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ContractID,

# Project Lead
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ProjectLeadResourceID,

# Account Owner
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $CompanyOwnerResourceID,

# Completed Percentage
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $CompletedPercentage,

# Completed date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $CompletedDateTime,

# Status Detail
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,2000)]
    [string[]]
    $StatusDetail,

# Status Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $StatusDateTime,

# Department
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Project -FieldName Department -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Project -FieldName Department -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $Department,

# Line Of Business
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Project -FieldName LineOfBusiness -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Project -FieldName LineOfBusiness -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $LineOfBusiness,

# purchase_order_number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $PurchaseOrderNumber,

# Business Division Subdivision ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $BusinessDivisionSubdivisionID,

# Last Activity By
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $LastActivityResourceID,

# Last Activity Date Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $LastActivityDateTime,

# Last Activity Person Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $LastActivityPersonType,

# Impersonator Creator Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ImpersonatorCreatorResourceID,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ProjectName', 'Status', 'AccountID', 'LineOfBusiness', 'ProjectCostEstimatedMarginPercentage', 'ExtPNumber', 'ChangeOrdersBudget', 'ExtProjectType', 'PurchaseOrderNumber', 'EndDateTime', 'StatusDateTime', 'ProjectNumber', 'Department', 'Type', 'Description', 'EstimatedSalesCost', 'CompletedDateTime', 'CreatorResourceID', 'OriginalEstimatedRevenue', 'LaborEstimatedCosts', 'LastActivityDateTime', 'SGDA', 'LaborEstimatedRevenue', 'ActualHours', 'ProjectLeadResourceID', 'ContractID', 'ProjectCostsBudget', 'ImpersonatorCreatorResourceID', 'ChangeOrdersRevenue', 'BusinessDivisionSubdivisionID', 'ActualBilledHours', 'EstimatedTime', 'ProjectCostsRevenue', 'LastActivityResourceID', 'id', 'CompanyOwnerResourceID', 'CompletedPercentage', 'LastActivityPersonType', 'CreateDateTime', 'Duration', 'LaborEstimatedMarginPercentage', 'StatusDetail', 'StartDateTime')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ProjectName', 'Status', 'AccountID', 'LineOfBusiness', 'ProjectCostEstimatedMarginPercentage', 'ExtPNumber', 'ChangeOrdersBudget', 'ExtProjectType', 'PurchaseOrderNumber', 'EndDateTime', 'StatusDateTime', 'ProjectNumber', 'Department', 'Type', 'Description', 'EstimatedSalesCost', 'CompletedDateTime', 'CreatorResourceID', 'OriginalEstimatedRevenue', 'LaborEstimatedCosts', 'LastActivityDateTime', 'SGDA', 'LaborEstimatedRevenue', 'ActualHours', 'ProjectLeadResourceID', 'ContractID', 'ProjectCostsBudget', 'ImpersonatorCreatorResourceID', 'ChangeOrdersRevenue', 'BusinessDivisionSubdivisionID', 'ActualBilledHours', 'EstimatedTime', 'ProjectCostsRevenue', 'LastActivityResourceID', 'id', 'CompanyOwnerResourceID', 'CompletedPercentage', 'LastActivityPersonType', 'CreateDateTime', 'Duration', 'LaborEstimatedMarginPercentage', 'StatusDetail', 'StartDateTime')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ProjectName', 'Status', 'AccountID', 'LineOfBusiness', 'ProjectCostEstimatedMarginPercentage', 'ExtPNumber', 'ChangeOrdersBudget', 'ExtProjectType', 'PurchaseOrderNumber', 'EndDateTime', 'StatusDateTime', 'ProjectNumber', 'Department', 'Type', 'Description', 'EstimatedSalesCost', 'CompletedDateTime', 'CreatorResourceID', 'OriginalEstimatedRevenue', 'LaborEstimatedCosts', 'LastActivityDateTime', 'SGDA', 'LaborEstimatedRevenue', 'ActualHours', 'ProjectLeadResourceID', 'ContractID', 'ProjectCostsBudget', 'ImpersonatorCreatorResourceID', 'ChangeOrdersRevenue', 'BusinessDivisionSubdivisionID', 'ActualBilledHours', 'EstimatedTime', 'ProjectCostsRevenue', 'LastActivityResourceID', 'id', 'CompanyOwnerResourceID', 'CompletedPercentage', 'LastActivityPersonType', 'CreateDateTime', 'Duration', 'LaborEstimatedMarginPercentage', 'StatusDetail', 'StartDateTime')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProjectName', 'AccountID', 'Type', 'ExtProjectType', 'ExtPNumber', 'ProjectNumber', 'Description', 'CreateDateTime', 'CreatorResourceID', 'StartDateTime', 'EndDateTime', 'Duration', 'ActualHours', 'ActualBilledHours', 'EstimatedTime', 'LaborEstimatedRevenue', 'LaborEstimatedCosts', 'LaborEstimatedMarginPercentage', 'ProjectCostsRevenue', 'ProjectCostsBudget', 'ProjectCostEstimatedMarginPercentage', 'ChangeOrdersRevenue', 'ChangeOrdersBudget', 'SGDA', 'OriginalEstimatedRevenue', 'EstimatedSalesCost', 'Status', 'ContractID', 'ProjectLeadResourceID', 'CompanyOwnerResourceID', 'CompletedPercentage', 'CompletedDateTime', 'StatusDetail', 'StatusDateTime', 'Department', 'LineOfBusiness', 'PurchaseOrderNumber', 'BusinessDivisionSubdivisionID', 'LastActivityResourceID', 'LastActivityDateTime', 'LastActivityPersonType', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProjectName', 'AccountID', 'Type', 'ExtProjectType', 'ExtPNumber', 'ProjectNumber', 'Description', 'CreateDateTime', 'CreatorResourceID', 'StartDateTime', 'EndDateTime', 'Duration', 'ActualHours', 'ActualBilledHours', 'EstimatedTime', 'LaborEstimatedRevenue', 'LaborEstimatedCosts', 'LaborEstimatedMarginPercentage', 'ProjectCostsRevenue', 'ProjectCostsBudget', 'ProjectCostEstimatedMarginPercentage', 'ChangeOrdersRevenue', 'ChangeOrdersBudget', 'SGDA', 'OriginalEstimatedRevenue', 'EstimatedSalesCost', 'Status', 'ContractID', 'ProjectLeadResourceID', 'CompanyOwnerResourceID', 'CompletedPercentage', 'CompletedDateTime', 'StatusDetail', 'StatusDateTime', 'Department', 'LineOfBusiness', 'PurchaseOrderNumber', 'BusinessDivisionSubdivisionID', 'LastActivityResourceID', 'LastActivityDateTime', 'LastActivityPersonType', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProjectName', 'AccountID', 'Type', 'ExtProjectType', 'ExtPNumber', 'ProjectNumber', 'Description', 'CreateDateTime', 'CreatorResourceID', 'StartDateTime', 'EndDateTime', 'Duration', 'ActualHours', 'ActualBilledHours', 'EstimatedTime', 'LaborEstimatedRevenue', 'LaborEstimatedCosts', 'LaborEstimatedMarginPercentage', 'ProjectCostsRevenue', 'ProjectCostsBudget', 'ProjectCostEstimatedMarginPercentage', 'ChangeOrdersRevenue', 'ChangeOrdersBudget', 'SGDA', 'OriginalEstimatedRevenue', 'EstimatedSalesCost', 'Status', 'ContractID', 'ProjectLeadResourceID', 'CompanyOwnerResourceID', 'CompletedPercentage', 'CompletedDateTime', 'StatusDetail', 'StatusDateTime', 'Department', 'LineOfBusiness', 'PurchaseOrderNumber', 'BusinessDivisionSubdivisionID', 'LastActivityResourceID', 'LastActivityDateTime', 'LastActivityPersonType', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProjectName', 'AccountID', 'Type', 'ExtProjectType', 'ExtPNumber', 'ProjectNumber', 'Description', 'CreateDateTime', 'CreatorResourceID', 'StartDateTime', 'EndDateTime', 'Duration', 'ActualHours', 'ActualBilledHours', 'EstimatedTime', 'LaborEstimatedRevenue', 'LaborEstimatedCosts', 'LaborEstimatedMarginPercentage', 'ProjectCostsRevenue', 'ProjectCostsBudget', 'ProjectCostEstimatedMarginPercentage', 'ChangeOrdersRevenue', 'ChangeOrdersBudget', 'SGDA', 'OriginalEstimatedRevenue', 'EstimatedSalesCost', 'Status', 'ContractID', 'ProjectLeadResourceID', 'CompanyOwnerResourceID', 'CompletedPercentage', 'CompletedDateTime', 'StatusDetail', 'StatusDateTime', 'Department', 'LineOfBusiness', 'PurchaseOrderNumber', 'BusinessDivisionSubdivisionID', 'LastActivityResourceID', 'LastActivityDateTime', 'LastActivityPersonType', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ProjectName', 'ExtPNumber', 'ProjectNumber', 'Description', 'StatusDetail', 'PurchaseOrderNumber')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ProjectName', 'ExtPNumber', 'ProjectNumber', 'Description', 'StatusDetail', 'PurchaseOrderNumber')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ProjectName', 'ExtPNumber', 'ProjectNumber', 'Description', 'StatusDetail', 'PurchaseOrderNumber')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ProjectName', 'ExtPNumber', 'ProjectNumber', 'Description', 'StatusDetail', 'PurchaseOrderNumber')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ProjectName', 'ExtPNumber', 'ProjectNumber', 'Description', 'StatusDetail', 'PurchaseOrderNumber')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('CreateDateTime', 'StartDateTime', 'EndDateTime', 'CompletedDateTime', 'StatusDateTime', 'LastActivityDateTime')]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'Project'
    
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
