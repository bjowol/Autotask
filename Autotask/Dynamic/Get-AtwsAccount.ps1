#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsAccount
{


<#
.SYNOPSIS
This function get one or more Account through the Autotask Web Services API.
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

AccountType
 

KeyAccountIcon
 

TerritoryID
 

MarketSegmentID
 

CompetitorID
 

BillToAddressToUse
 

InvoiceMethod
 

ApiVendorID
 

Entities that have fields that refer to the base entity of this CmdLet:

Account
 AccountAlert
 AccountLocation
 AccountNote
 AccountPhysicalLocation
 AccountTeam
 AccountToDo
 BillingItem
 ComanagedAssociation
 Contact
 Contract
 ContractServiceUnit
 ExpenseItem
 InstalledProduct
 Invoice
 NotificationHistory
 Opportunity
 Product
 ProductVendor
 Project
 PurchaseOrder
 Quote
 SalesOrder
 Service
 ServiceCall
 Subscription
 SurveyResults
 Ticket

.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.Account[]]. This function outputs the Autotask.Account that was returned by the API.
.EXAMPLE
Get-AtwsAccount -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsAccount -AccountName SomeName
Returns the object with AccountName 'SomeName', if any.
 .EXAMPLE
Get-AtwsAccount -AccountName 'Some Name'
Returns the object with AccountName 'Some Name', if any.
 .EXAMPLE
Get-AtwsAccount -AccountName 'Some Name' -NotEquals AccountName
Returns any objects with a AccountName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsAccount -AccountName SomeName* -Like AccountName
Returns any object with a AccountName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsAccount -AccountName SomeName* -NotLike AccountName
Returns any object with a AccountName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsAccount -AccountType <PickList Label>
Returns any Accounts with property AccountType equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsAccount -AccountType <PickList Label> -NotEquals AccountType 
Returns any Accounts with property AccountType NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsAccount -AccountType <PickList Label1>, <PickList Label2>
Returns any Accounts with property AccountType equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsAccount -AccountType <PickList Label1>, <PickList Label2> -NotEquals AccountType
Returns any Accounts with property AccountType NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsAccount -Id 1234 -AccountName SomeName* -AccountType <PickList Label1>, <PickList Label2> -Like AccountName -NotEquals AccountType -GreaterThan Id
An example of a more complex query. This command returns any Accounts with Id GREATER THAN 1234, a AccountName that matches the simple pattern SomeName* AND that has a AccountType that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-AtwsAccount
 .LINK
Set-AtwsAccount

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
    [ValidateSet('BillToAccountPhysicalLocationID', 'BillToCountryID', 'CountryID', 'CreatedByResourceID', 'CurrencyID', 'ImpersonatorCreatorResourceID', 'InvoiceTemplateID', 'OwnerResourceID', 'ParentAccountID', 'QuoteTemplateID', 'TaxRegionID')]
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
    [ValidateSet('Account:ParentAccountID', 'AccountAlert:AccountID', 'AccountLocation:AccountID', 'AccountNote:AccountID', 'AccountPhysicalLocation:AccountID', 'AccountTeam:AccountID', 'AccountToDo:AccountID', 'BillingItem:AccountID', 'BillingItem:VendorID', 'ComanagedAssociation:AccountID', 'Contact:AccountID', 'Contract:AccountID', 'Contract:BillToAccountID', 'ContractServiceUnit:VendorAccountID', 'ExpenseItem:AccountID', 'InstalledProduct:AccountID', 'InstalledProduct:VendorID', 'Invoice:AccountID', 'NotificationHistory:AccountID', 'Opportunity:AccountID', 'Product:DefaultVendorID', 'ProductVendor:VendorID', 'Project:AccountID', 'PurchaseOrder:PurchaseForAccountID', 'PurchaseOrder:VendorID', 'Quote:AccountID', 'SalesOrder:AccountID', 'Service:VendorAccountID', 'ServiceCall:AccountID', 'Subscription:VendorID', 'SurveyResults:AccountID', 'Ticket:AccountID')]
    [string]
    $GetExternalEntityByThisEntityId,

# Return all objects in one query
    [Parameter(
      ParametersetName = 'Get_all'
    )]
    [switch]
    $All,

# A single user defined field can be used pr query
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Alias('UDF')]
    [ValidateNotNullOrEmpty()]
    [Autotask.UserDefinedField]
    $UserDefinedField,

# Client ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Client Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Alias('Name')]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,100)]
    [string[]]
    $AccountName,

# Address 1
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,128)]
    [string[]]
    $Address1,

# Address 2
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,128)]
    [string[]]
    $Address2,

# City
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,30)]
    [string[]]
    $City,

# County
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,40)]
    [string[]]
    $State,

# Postal Code
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,10)]
    [string[]]
    $PostalCode,

# Country
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string[]]
    $Country,

# Phone
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,25)]
    [string[]]
    $Phone,

# Alternate Phone 1
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,25)]
    [string[]]
    $AlternatePhone1,

# Alternate Phone 2
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,25)]
    [string[]]
    $AlternatePhone2,

# Fax
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,25)]
    [string[]]
    $Fax,

# Web
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,255)]
    [string[]]
    $WebAddress,

# Client Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Account -FieldName AccountType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Account -FieldName AccountType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $AccountType,

# Key Account Icon
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Account -FieldName KeyAccountIcon -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Account -FieldName KeyAccountIcon -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $KeyAccountIcon,

# Client Owner
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[Int][]]
    $OwnerResourceID,

# Territory Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Account -FieldName TerritoryID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Account -FieldName TerritoryID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $TerritoryID,

# Market Segment
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Account -FieldName MarketSegmentID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Account -FieldName MarketSegmentID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $MarketSegmentID,

# Competitor
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Account -FieldName CompetitorID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Account -FieldName CompetitorID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $CompetitorID,

# Parent Client
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ParentAccountID,

# Client Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $AccountNumber,

# Create Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $CreateDate,

# Last Activity Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $LastActivityDate,

# Account Active
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $Active,

# TaskFire Active
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $TaskFireActive,

# Client Portal Active
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $ClientPortalActive,

# Tax Region ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $TaxRegionID,

# Tax Exempt
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $TaxExempt,

# Tax ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $TaxID,

# Additional Address Information
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string[]]
    $AdditionalAddressInformation,

# Country ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $CountryID,

# Bill To Address to Use
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Account -FieldName BillToAddressToUse -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Account -FieldName BillToAddressToUse -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $BillToAddressToUse,

# Bill To Attention
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $BillToAttention,

# Bill To Address Line 1
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,150)]
    [string[]]
    $BillToAddress1,

# Bill To Address Line 2
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,150)]
    [string[]]
    $BillToAddress2,

# Bill To City
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $BillToCity,

# Bill To County
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,128)]
    [string[]]
    $BillToState,

# Bill To Postal Code
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string[]]
    $BillToZipCode,

# Bill To Country ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $BillToCountryID,

# Bill To Additional Address Information
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string[]]
    $BillToAdditionalAddressInformation,

# Transmission Method
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Account -FieldName InvoiceMethod -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Account -FieldName InvoiceMethod -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $InvoiceMethod,

# Invoice non contract items to Parent Client
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $InvoiceNonContractItemsToParentAccount,

# Quote Template ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $QuoteTemplateID,

# Quote Email Message ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $QuoteEmailMessageID,

# Invoice Template ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $InvoiceTemplateID,

# Invoice Email Message ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $InvoiceEmailMessageID,

# Currency ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $CurrencyID,

# Bill To Account Physical Location ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $BillToAccountPhysicalLocationID,

# Survey Account Rating
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[double][]]
    $SurveyAccountRating,

# Created By Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $CreatedByResourceID,

# API Vendor ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Account -FieldName ApiVendorID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Account -FieldName ApiVendorID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $ApiVendorID,

# Enabled For Comanaged
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $EnabledForComanaged,

# Impersonator Creator Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $ImpersonatorCreatorResourceID,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'Active', 'TaskFireActive', 'ClientPortalActive', 'TaxRegionID', 'TaxExempt', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'InvoiceNonContractItemsToParentAccount', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'CreatedByResourceID', 'ApiVendorID', 'EnabledForComanaged', 'ImpersonatorCreatorResourceID', 'UserDefinedField')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'Active', 'TaskFireActive', 'ClientPortalActive', 'TaxRegionID', 'TaxExempt', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'InvoiceNonContractItemsToParentAccount', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'CreatedByResourceID', 'ApiVendorID', 'EnabledForComanaged', 'ImpersonatorCreatorResourceID', 'UserDefinedField')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'Active', 'TaskFireActive', 'ClientPortalActive', 'TaxRegionID', 'TaxExempt', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'InvoiceNonContractItemsToParentAccount', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'CreatedByResourceID', 'ApiVendorID', 'EnabledForComanaged', 'ImpersonatorCreatorResourceID', 'UserDefinedField')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'TaxRegionID', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'CreatedByResourceID', 'ApiVendorID', 'ImpersonatorCreatorResourceID', 'UserDefinedField')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'TaxRegionID', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'CreatedByResourceID', 'ApiVendorID', 'ImpersonatorCreatorResourceID', 'UserDefinedField')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'TaxRegionID', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'CreatedByResourceID', 'ApiVendorID', 'ImpersonatorCreatorResourceID', 'UserDefinedField')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'TaxRegionID', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'CreatedByResourceID', 'ApiVendorID', 'ImpersonatorCreatorResourceID', 'UserDefinedField')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('CreateDate', 'LastActivityDate', 'UserDefinedField')]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'Account'
    
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
