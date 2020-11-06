#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsProduct
{


<#
.SYNOPSIS
This function get one or more Product through the Autotask Web Services API.
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

ProductCategory
 

PeriodType
 

BillingType
 

PriceCostMethod
 

Entities that have fields that refer to the base entity of this CmdLet:

ChangeOrderCost
 ContactBillingProductAssociation
 ContractBillingRule
 ContractCost
 InstalledProduct
 InstalledProductBillingProductAssociation
 InventoryItem
 InventoryTransfer
 Opportunity
 PriceListProduct
 ProductTier
 ProductVendor
 ProjectCost
 PurchaseOrderItem
 QuoteItem
 TicketCost

.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.Product[]]. This function outputs the Autotask.Product that was returned by the API.
.EXAMPLE
Get-AtwsProduct -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsProduct -ProductName SomeName
Returns the object with ProductName 'SomeName', if any.
 .EXAMPLE
Get-AtwsProduct -ProductName 'Some Name'
Returns the object with ProductName 'Some Name', if any.
 .EXAMPLE
Get-AtwsProduct -ProductName 'Some Name' -NotEquals ProductName
Returns any objects with a ProductName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsProduct -ProductName SomeName* -Like ProductName
Returns any object with a ProductName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsProduct -ProductName SomeName* -NotLike ProductName
Returns any object with a ProductName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsProduct -ProductCategory <PickList Label>
Returns any Products with property ProductCategory equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsProduct -ProductCategory <PickList Label> -NotEquals ProductCategory 
Returns any Products with property ProductCategory NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsProduct -ProductCategory <PickList Label1>, <PickList Label2>
Returns any Products with property ProductCategory equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsProduct -ProductCategory <PickList Label1>, <PickList Label2> -NotEquals ProductCategory
Returns any Products with property ProductCategory NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsProduct -Id 1234 -ProductName SomeName* -ProductCategory <PickList Label1>, <PickList Label2> -Like ProductName -NotEquals ProductCategory -GreaterThan Id
An example of a more complex query. This command returns any Products with Id GREATER THAN 1234, a ProductName that matches the simple pattern SomeName* AND that has a ProductCategory that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-AtwsProduct
 .LINK
Set-AtwsProduct

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
    [ValidateSet('CostAllocationCodeID', 'DefaultVendorID', 'ImpersonatorCreatorResourceID', 'ProductAllocationCodeID')]
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
    [ValidateSet('ChangeOrderCost:ProductID', 'ContactBillingProductAssociation:BillingProductID', 'ContractBillingRule:ProductID', 'ContractCost:ProductID', 'InstalledProduct:ProductID', 'InstalledProductBillingProductAssociation:BillingProductID', 'InventoryItem:ProductID', 'InventoryTransfer:ProductID', 'Opportunity:ProductID', 'PriceListProduct:ProductID', 'ProductTier:ProductID', 'ProductVendor:ProductID', 'ProjectCost:ProductID', 'PurchaseOrderItem:ProductID', 'QuoteItem:ProductID', 'TicketCost:ProductID')]
    [string]
    $GetExternalEntityByThisEntityId,

# Return all objects in one query
    [Parameter(
      ParametersetName = 'Get_all'
    )]
    [switch]
    $All,

# ProductID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Product Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,100)]
    [string[]]
    $Name,

# Product Description
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,2000)]
    [string[]]
    $Description,

# Product SKU
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $SKU,

# Product Link
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,500)]
    [string[]]
    $Link,

# Product Category
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Product -FieldName ProductCategory -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Product -FieldName ProductCategory -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $ProductCategory,

# External ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $ExternalProductID,

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

# MSRP
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $MSRP,

# Vendor Account ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $DefaultVendorID,

# Vendor Product Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $VendorProductNumber,

# Manufacturer Account Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string[]]
    $ManufacturerName,

# Manufacturer Product Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $ManufacturerProductName,

# Active
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[boolean][]]
    $Active,

# Period Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Product -FieldName PeriodType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Product -FieldName PeriodType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $PeriodType,

# Allocation Code ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[Int][]]
    $ProductAllocationCodeID,

# Is Serialized
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[boolean][]]
    $Serialized,

# Cost Allocation Code ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $CostAllocationCodeID,

# Does Not Require Procurement
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $DoesNotRequireProcurement,

# markup_rate
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $MarkupRate,

# Internal Product ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $InternalProductID,

# Billing Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Product -FieldName BillingType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Product -FieldName BillingType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $BillingType,

# Price Cost Method
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Product -FieldName PriceCostMethod -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Product -FieldName PriceCostMethod -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $PriceCostMethod,

# Eligible For RMA
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $EligibleForRma,

# Impersonator Creator Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ImpersonatorCreatorResourceID,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Description', 'SKU', 'Link', 'ProductCategory', 'ExternalProductID', 'UnitCost', 'UnitPrice', 'MSRP', 'DefaultVendorID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'Active', 'PeriodType', 'ProductAllocationCodeID', 'Serialized', 'CostAllocationCodeID', 'DoesNotRequireProcurement', 'MarkupRate', 'InternalProductID', 'BillingType', 'PriceCostMethod', 'EligibleForRma', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Description', 'SKU', 'Link', 'ProductCategory', 'ExternalProductID', 'UnitCost', 'UnitPrice', 'MSRP', 'DefaultVendorID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'Active', 'PeriodType', 'ProductAllocationCodeID', 'Serialized', 'CostAllocationCodeID', 'DoesNotRequireProcurement', 'MarkupRate', 'InternalProductID', 'BillingType', 'PriceCostMethod', 'EligibleForRma', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Description', 'SKU', 'Link', 'ProductCategory', 'ExternalProductID', 'UnitCost', 'UnitPrice', 'MSRP', 'DefaultVendorID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'Active', 'PeriodType', 'ProductAllocationCodeID', 'Serialized', 'CostAllocationCodeID', 'DoesNotRequireProcurement', 'MarkupRate', 'InternalProductID', 'BillingType', 'PriceCostMethod', 'EligibleForRma', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Description', 'SKU', 'Link', 'ProductCategory', 'ExternalProductID', 'UnitCost', 'UnitPrice', 'MSRP', 'DefaultVendorID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'ProductAllocationCodeID', 'CostAllocationCodeID', 'MarkupRate', 'InternalProductID', 'BillingType', 'PriceCostMethod', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Description', 'SKU', 'Link', 'ProductCategory', 'ExternalProductID', 'UnitCost', 'UnitPrice', 'MSRP', 'DefaultVendorID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'ProductAllocationCodeID', 'CostAllocationCodeID', 'MarkupRate', 'InternalProductID', 'BillingType', 'PriceCostMethod', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Description', 'SKU', 'Link', 'ProductCategory', 'ExternalProductID', 'UnitCost', 'UnitPrice', 'MSRP', 'DefaultVendorID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'ProductAllocationCodeID', 'CostAllocationCodeID', 'MarkupRate', 'InternalProductID', 'BillingType', 'PriceCostMethod', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Description', 'SKU', 'Link', 'ProductCategory', 'ExternalProductID', 'UnitCost', 'UnitPrice', 'MSRP', 'DefaultVendorID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'ProductAllocationCodeID', 'CostAllocationCodeID', 'MarkupRate', 'InternalProductID', 'BillingType', 'PriceCostMethod', 'ImpersonatorCreatorResourceID')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'SKU', 'Link', 'ExternalProductID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'InternalProductID')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'SKU', 'Link', 'ExternalProductID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'InternalProductID')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'SKU', 'Link', 'ExternalProductID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'InternalProductID')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'SKU', 'Link', 'ExternalProductID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'InternalProductID')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Description', 'SKU', 'Link', 'ExternalProductID', 'VendorProductNumber', 'ManufacturerName', 'ManufacturerProductName', 'PeriodType', 'InternalProductID')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'Product'
    
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
