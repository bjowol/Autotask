#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsBillingItem
{


<#
.SYNOPSIS
This function get one or more BillingItem through the Autotask Web Services API.
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
SubType

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.BillingItem[]]. This function outputs the Autotask.BillingItem that was returned by the API.
.EXAMPLE
Get-AtwsBillingItem -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsBillingItem -BillingItemName SomeName
Returns the object with BillingItemName 'SomeName', if any.
 .EXAMPLE
Get-AtwsBillingItem -BillingItemName 'Some Name'
Returns the object with BillingItemName 'Some Name', if any.
 .EXAMPLE
Get-AtwsBillingItem -BillingItemName 'Some Name' -NotEquals BillingItemName
Returns any objects with a BillingItemName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsBillingItem -BillingItemName SomeName* -Like BillingItemName
Returns any object with a BillingItemName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsBillingItem -BillingItemName SomeName* -NotLike BillingItemName
Returns any object with a BillingItemName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsBillingItem -Type <PickList Label>
Returns any BillingItems with property Type equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsBillingItem -Type <PickList Label> -NotEquals Type 
Returns any BillingItems with property Type NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsBillingItem -Type <PickList Label1>, <PickList Label2>
Returns any BillingItems with property Type equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsBillingItem -Type <PickList Label1>, <PickList Label2> -NotEquals Type
Returns any BillingItems with property Type NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsBillingItem -Id 1234 -BillingItemName SomeName* -Type <PickList Label1>, <PickList Label2> -Like BillingItemName -NotEquals Type -GreaterThan Id
An example of a more complex query. This command returns any BillingItems with Id GREATER THAN 1234, a BillingItemName that matches the simple pattern SomeName* AND that has a Type that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
Set-AtwsBillingItem

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
    [ValidateSet('AccountID', 'AccountManagerWhenApprovedID', 'AllocationCodeID', 'BusinessDivisionSubdivisionID', 'ContractCostID', 'ContractID', 'ExpenseItemID', 'InstalledProductID', 'InvoiceID', 'ItemApproverID', 'MilestoneID', 'ProjectCostID', 'ProjectID', 'RoleID', 'ServiceBundleID', 'ServiceID', 'TaskID', 'TicketCostID', 'TicketID', 'TimeEntryID', 'VendorID')]
    [string]
    $GetReferenceEntityById,

# Return all objects in one query
    [Parameter(
      ParametersetName = 'Get_all'
    )]
    [switch]
    $All,

# Client
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $AccountID,

# AccountManagerWhenApprovedID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $AccountManagerWhenApprovedID,

# AllocationCodeID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $AllocationCodeID,

# Business Division Subdivision ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $BusinessDivisionSubdivisionID,

# Contract Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $ContractCostID,

# ContractID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ContractID,

# Description
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,2000)]
    [string[]]
    $Description,

# Expense Item
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ExpenseItemID,

# ExtendedPrice
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $ExtendedPrice,

# BillingItemID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Installed Product Id
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $InstalledProductID,

# InternalCurrencyExtendedPrice
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $InternalCurrencyExtendedPrice,

# InternalCurrencyRate
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $InternalCurrencyRate,

# InternalCurrencyTaxDollars
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $InternalCurrencyTaxDollars,

# InternalCurrencyTotalAmount
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $InternalCurrencyTotalAmount,

# InvoiceID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $InvoiceID,

# ItemApproverID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ItemApproverID,

# ItemDate
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $ItemDate,

# ItemName
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,255)]
    [string[]]
    $ItemName,

# Invoice Line Item ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $LineItemID,

# Milestone ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $MilestoneID,

# NonBillable
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[Int][]]
    $NonBillable,

# OurCost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $OurCost,

# Posted Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $PostedDate,

# Posted On Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $PostedOnTime,

# Project Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $ProjectCostID,

# ProjectID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ProjectID,

# purchase_order_number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $PurchaseOrderNumber,

# Quantity
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $Quantity,

# Rate
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $Rate,

# RoleID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $RoleID,

# Service Bundle ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $ServiceBundleID,

# Service ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $ServiceID,

# Sub Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity BillingItem -FieldName SubType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity BillingItem -FieldName SubType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $SubType,

# TaskID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $TaskID,

# TaxDollars
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $TaxDollars,

# Ticket Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $TicketCostID,

# TicketID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $TicketID,

# TimeEntryID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $TimeEntryID,

# TotalAmount
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $TotalAmount,

# Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity BillingItem -FieldName Type -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity BillingItem -FieldName Type -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $Type,

# Vendor ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $VendorID,

# WebServiceDate
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $WebServiceDate,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('InstalledProductID', 'PostedDate', 'RoleID', 'ServiceBundleID', 'TaxDollars', 'ItemName', 'InternalCurrencyRate', 'Type', 'WebServiceDate', 'BusinessDivisionSubdivisionID', 'AccountID', 'Rate', 'InvoiceID', 'VendorID', 'TimeEntryID', 'ItemDate', 'ExpenseItemID', 'LineItemGroupDescription', 'SubType', 'ContractCostID', 'ItemApproverID', 'id', 'LineItemID', 'InternalCurrencyExtendedPrice', 'TotalAmount', 'Quantity', 'NonBillable', 'PurchaseOrderNumber', 'ExtendedPrice', 'MilestoneID', 'AllocationCodeID', 'ProjectID', 'LineItemFullDescription', 'ServiceID', 'InternalCurrencyTotalAmount', 'ContractID', 'Description', 'AccountManagerWhenApprovedID', 'TicketCostID', 'TicketID', 'PostedOnTime', 'TaskID', 'OurCost', 'ProjectCostID', 'InternalCurrencyTaxDollars')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('InstalledProductID', 'PostedDate', 'RoleID', 'ServiceBundleID', 'TaxDollars', 'ItemName', 'InternalCurrencyRate', 'Type', 'WebServiceDate', 'BusinessDivisionSubdivisionID', 'AccountID', 'Rate', 'InvoiceID', 'VendorID', 'TimeEntryID', 'ItemDate', 'ExpenseItemID', 'LineItemGroupDescription', 'SubType', 'ContractCostID', 'ItemApproverID', 'id', 'LineItemID', 'InternalCurrencyExtendedPrice', 'TotalAmount', 'Quantity', 'NonBillable', 'PurchaseOrderNumber', 'ExtendedPrice', 'MilestoneID', 'AllocationCodeID', 'ProjectID', 'LineItemFullDescription', 'ServiceID', 'InternalCurrencyTotalAmount', 'ContractID', 'Description', 'AccountManagerWhenApprovedID', 'TicketCostID', 'TicketID', 'PostedOnTime', 'TaskID', 'OurCost', 'ProjectCostID', 'InternalCurrencyTaxDollars')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('InstalledProductID', 'PostedDate', 'RoleID', 'ServiceBundleID', 'TaxDollars', 'ItemName', 'InternalCurrencyRate', 'Type', 'WebServiceDate', 'BusinessDivisionSubdivisionID', 'AccountID', 'Rate', 'InvoiceID', 'VendorID', 'TimeEntryID', 'ItemDate', 'ExpenseItemID', 'LineItemGroupDescription', 'SubType', 'ContractCostID', 'ItemApproverID', 'id', 'LineItemID', 'InternalCurrencyExtendedPrice', 'TotalAmount', 'Quantity', 'NonBillable', 'PurchaseOrderNumber', 'ExtendedPrice', 'MilestoneID', 'AllocationCodeID', 'ProjectID', 'LineItemFullDescription', 'ServiceID', 'InternalCurrencyTotalAmount', 'ContractID', 'Description', 'AccountManagerWhenApprovedID', 'TicketCostID', 'TicketID', 'PostedOnTime', 'TaskID', 'OurCost', 'ProjectCostID', 'InternalCurrencyTaxDollars')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Type', 'SubType', 'ItemName', 'Description', 'Quantity', 'Rate', 'TotalAmount', 'OurCost', 'ItemDate', 'InvoiceID', 'ItemApproverID', 'AccountID', 'TicketID', 'TaskID', 'ProjectID', 'AllocationCodeID', 'RoleID', 'TimeEntryID', 'ContractID', 'WebServiceDate', 'NonBillable', 'TaxDollars', 'PurchaseOrderNumber', 'ExtendedPrice', 'ExpenseItemID', 'ContractCostID', 'ProjectCostID', 'TicketCostID', 'LineItemID', 'MilestoneID', 'ServiceID', 'ServiceBundleID', 'VendorID', 'LineItemFullDescription', 'LineItemGroupDescription', 'InstalledProductID', 'InternalCurrencyExtendedPrice', 'InternalCurrencyRate', 'InternalCurrencyTaxDollars', 'InternalCurrencyTotalAmount', 'AccountManagerWhenApprovedID', 'BusinessDivisionSubdivisionID', 'PostedOnTime', 'PostedDate')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Type', 'SubType', 'ItemName', 'Description', 'Quantity', 'Rate', 'TotalAmount', 'OurCost', 'ItemDate', 'InvoiceID', 'ItemApproverID', 'AccountID', 'TicketID', 'TaskID', 'ProjectID', 'AllocationCodeID', 'RoleID', 'TimeEntryID', 'ContractID', 'WebServiceDate', 'NonBillable', 'TaxDollars', 'PurchaseOrderNumber', 'ExtendedPrice', 'ExpenseItemID', 'ContractCostID', 'ProjectCostID', 'TicketCostID', 'LineItemID', 'MilestoneID', 'ServiceID', 'ServiceBundleID', 'VendorID', 'LineItemFullDescription', 'LineItemGroupDescription', 'InstalledProductID', 'InternalCurrencyExtendedPrice', 'InternalCurrencyRate', 'InternalCurrencyTaxDollars', 'InternalCurrencyTotalAmount', 'AccountManagerWhenApprovedID', 'BusinessDivisionSubdivisionID', 'PostedOnTime', 'PostedDate')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Type', 'SubType', 'ItemName', 'Description', 'Quantity', 'Rate', 'TotalAmount', 'OurCost', 'ItemDate', 'InvoiceID', 'ItemApproverID', 'AccountID', 'TicketID', 'TaskID', 'ProjectID', 'AllocationCodeID', 'RoleID', 'TimeEntryID', 'ContractID', 'WebServiceDate', 'NonBillable', 'TaxDollars', 'PurchaseOrderNumber', 'ExtendedPrice', 'ExpenseItemID', 'ContractCostID', 'ProjectCostID', 'TicketCostID', 'LineItemID', 'MilestoneID', 'ServiceID', 'ServiceBundleID', 'VendorID', 'LineItemFullDescription', 'LineItemGroupDescription', 'InstalledProductID', 'InternalCurrencyExtendedPrice', 'InternalCurrencyRate', 'InternalCurrencyTaxDollars', 'InternalCurrencyTotalAmount', 'AccountManagerWhenApprovedID', 'BusinessDivisionSubdivisionID', 'PostedOnTime', 'PostedDate')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Type', 'SubType', 'ItemName', 'Description', 'Quantity', 'Rate', 'TotalAmount', 'OurCost', 'ItemDate', 'InvoiceID', 'ItemApproverID', 'AccountID', 'TicketID', 'TaskID', 'ProjectID', 'AllocationCodeID', 'RoleID', 'TimeEntryID', 'ContractID', 'WebServiceDate', 'NonBillable', 'TaxDollars', 'PurchaseOrderNumber', 'ExtendedPrice', 'ExpenseItemID', 'ContractCostID', 'ProjectCostID', 'TicketCostID', 'LineItemID', 'MilestoneID', 'ServiceID', 'ServiceBundleID', 'VendorID', 'LineItemFullDescription', 'LineItemGroupDescription', 'InstalledProductID', 'InternalCurrencyExtendedPrice', 'InternalCurrencyRate', 'InternalCurrencyTaxDollars', 'InternalCurrencyTotalAmount', 'AccountManagerWhenApprovedID', 'BusinessDivisionSubdivisionID', 'PostedOnTime', 'PostedDate')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName', 'Description', 'PurchaseOrderNumber', 'LineItemFullDescription', 'LineItemGroupDescription')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName', 'Description', 'PurchaseOrderNumber', 'LineItemFullDescription', 'LineItemGroupDescription')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName', 'Description', 'PurchaseOrderNumber', 'LineItemFullDescription', 'LineItemGroupDescription')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName', 'Description', 'PurchaseOrderNumber', 'LineItemFullDescription', 'LineItemGroupDescription')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName', 'Description', 'PurchaseOrderNumber', 'LineItemFullDescription', 'LineItemGroupDescription')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemDate', 'WebServiceDate', 'PostedOnTime', 'PostedDate')]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'BillingItem'
    
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
        
        $result = [Collections.ArrayList]::new()
        $iterations = [Collections.Arraylist]::new()
    }


    process {
        # Parameterset Get_All has a single parameter: -All
        # Set the Filter manually to get every single object of this type 
        if ($PSCmdlet.ParameterSetName -eq 'Get_all') { 
            $Filter = @('id', '-ge', 0)
            [void]$iterations.Add($Filter)
        }
        # So it is not -All. If Filter does not exist it has to be By_parameters
        elseif (-not ($Filter)) {
    
            Write-Debug ('{0}: Query based on parameters, parsing' -F $MyInvocation.MyCommand.Name)
            
            # find parameter with highest count
            $index = @{}
            $max = ($PSBoundParameters.getenumerator() | foreach-object { $index[$_.count] = $_.key ; $_.count } | Sort-Object -Descending)[0]
            $param = $index[$max]
            # Extract the parameter content, sort it ascending (we assume it is an Id field)
            # and deduplicate
            $count = $PSBoundParameters[$param].count

            # Check number of values. If it is less than or equal to 200 we pass PSBoundParameters as is
            if ($count -le 200) { 
                [string[]]$Filter = ConvertTo-AtwsFilter -BoundParameters $PSBoundParameters -EntityName $entityName
                [void]$iterations.Add($Filter)
            }
            # More than 200 values. This will cause a SQL query nested too much. Break a single parameter
            # into segments and create multiple queries with max 200 values
            else {
                # Deduplicate the value list or the same ID may be included in more than 1 query
                $outerLoop = $PSBoundParameters[$param] | Sort-Object -Unique

                Write-Verbose ('{0}: Received {1} objects containing {2} unique values for parameter {3}' -f $MyInvocation.MyCommand.Name, $count, $outerLoop.Count, $param)

                # Make a writable copy of PSBoundParameters
                $BoundParameters = $PSBoundParameters
                for ($i = 0; $i -lt $outerLoop.count; $i += 200) {
                    $j = $i + 199
                    if ($j -ge $outerLoop.count) {
                        $j = $outerLoop.count - 1
                    } 

                    # make a selection
                    $BoundParameters[$param] = $outerLoop[$i .. $j]
                    
                    Write-Verbose ('{0}: Asking for {1} values {2} to {3}' -f $MyInvocation.MyCommand.Name, $param, $i, $j)
            
                    # Convert named parameters to a filter definition that can be parsed to QueryXML
                    [string[]]$Filter = ConvertTo-AtwsFilter -BoundParameters $BoundParameters -EntityName $entityName
                    [void]$iterations.Add($Filter)
                }
            }
        }
        # Not parameters, nor Get_all. There are only three parameter sets, so now we know
        # that we were passed a Filter
        else {
      
            Write-Debug ('{0}: Query based on manual filter, parsing' -F $MyInvocation.MyCommand.Name)
            
            # Parse the filter string and expand variables in _this_ scope (dot-sourcing)
            # or the variables will not be available and expansion will fail
            $Filter = . Update-AtwsFilter -Filterstring $Filter
            [void]$iterations.Add($Filter)
        } 

        # Prepare shouldProcess comments
        $caption = $MyInvocation.MyCommand.Name
        $verboseDescription = '{0}: About to query the Autotask Web API for {1}(s).' -F $caption, $entityName
        $verboseWarning = '{0}: About to query the Autotask Web API for {1}(s). Do you want to continue?' -F $caption, $entityName
    
        # Lets do it and say we didn't!
        if ($PSCmdlet.ShouldProcess($verboseDescription, $verboseWarning, $caption)) { 
            foreach ($Filter in $iterations) { 

                try { 
                    # Make the query and pass the optional parameters to Get-AtwsData
                    $response = Get-AtwsData -Entity $entityName -Filter $Filter `
                        -NoPickListLabel:$NoPickListLabel.IsPresent `
                        -GetReferenceEntityById $GetReferenceEntityById
                }
                catch {
                    write-host "ERROR: " -ForegroundColor Red -NoNewline
                    write-host $_.Exception.Message
                    write-host ("{0}: {1}" -f $_.CategoryInfo.Category,$_.CategoryInfo.Reason) -ForegroundColor Cyan
                    $_.ScriptStackTrace -split '\n' | ForEach-Object {
                        Write-host "  |  " -ForegroundColor Cyan -NoNewline
                        Write-host $_
                    }
                }
                # If multiple items use .addrange(). If a single item use .add()
                if ($response.count -gt 1) { 
                    [void]$result.AddRange($response)
                }
                else {
                    [void]$result.Add($response)
                }
                Write-Verbose ('{0}: Number of entities returned by base query: {1}' -F $MyInvocation.MyCommand.Name, $result.Count)
            }
        }
    }

    end {
        Write-Debug ('{0}: End of function' -F $MyInvocation.MyCommand.Name)
        if ($result) {
            Return $result
        }
    }


}
