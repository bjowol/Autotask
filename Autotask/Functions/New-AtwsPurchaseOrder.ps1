#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function New-AtwsPurchaseOrder
{


<#
.SYNOPSIS
This function creates a new PurchaseOrder through the Autotask Web Services API. All required properties are marked as required parameters to assist you on the command line.
.DESCRIPTION
The function supports all properties of an [Autotask.PurchaseOrder] that can be updated through the Web Services API. The function uses PowerShell parameter validation  and supports IntelliSense for selecting picklist values. Any required paramterer is marked as Mandatory in the PowerShell function to assist you on the command line.

If you need very complicated queries you can write a filter directly and pass it using the -Filter parameter. To get the PurchaseOrder with Id number 0 you could write 'New-AtwsPurchaseOrder -Id 0' or you could write 'New-AtwsPurchaseOrder -Filter {Id -eq 0}.

'New-AtwsPurchaseOrder -Id 0,4' could be written as 'New-AtwsPurchaseOrder -Filter {id -eq 0 -or id -eq 4}'. For simple queries you can see that using parameters is much easier than the -Filter option. But the -Filter option supports an arbitrary sequence of most operators (-eq, -ne, -gt, -ge, -lt, -le, -and, -or, -beginswith, -endswith, -contains, -like, -notlike, -soundslike, -isnotnull, -isnull, -isthisday). As you can group them using parenthesis '()' you can write arbitrarily complex queries with -Filter. 

To create a new PurchaseOrder you need the following required fields:
 -VendorID
 -Status
 -ShipToName
 -ShipToAddress1

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.PurchaseOrder]. This function outputs the Autotask.PurchaseOrder that was created by the API.
.EXAMPLE
$result = New-AtwsPurchaseOrder -VendorID [Value] -Status [Value] -ShipToName [Value] -ShipToAddress1 [Value]
Creates a new [Autotask.PurchaseOrder] through the Web Services API and returns the new object.
 .EXAMPLE
$result = Get-AtwsPurchaseOrder -Id 124 | New-AtwsPurchaseOrder 
Copies [Autotask.PurchaseOrder] by Id 124 to a new object through the Web Services API and returns the new object.
 .EXAMPLE
Get-AtwsPurchaseOrder -Id 124 | New-AtwsPurchaseOrder | Set-AtwsPurchaseOrder -ParameterName <Parameter Value>
Copies [Autotask.PurchaseOrder] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsPurchaseOrder to modify the object.
 .EXAMPLE
$result = Get-AtwsPurchaseOrder -Id 124 | New-AtwsPurchaseOrder | Set-AtwsPurchaseOrder -ParameterName <Parameter Value> -Passthru
Copies [Autotask.PurchaseOrder] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsPurchaseOrder to modify the object and returns the new object.

.LINK
Get-AtwsPurchaseOrder
 .LINK
Set-AtwsPurchaseOrder

#>

  [CmdLetBinding(SupportsShouldProcess = $true, DefaultParameterSetName='By_parameters', ConfirmImpact='Low')]
  Param
  (
# An array of objects to create
    [Parameter(
      ParametersetName = 'Input_Object',
      ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [Autotask.PurchaseOrder[]]
    $InputObject,

# Cancel Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $CancelDateTime,

# Create Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $CreateDateTime,

# Creator Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $CreatorResourceID,

# External Purchase Order Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string]
    $ExternalPONumber,

# Fax
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,25)]
    [string]
    $Fax,

# Freight Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [double]
    $Freight,

# General Memo
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,4000)]
    [string]
    $GeneralMemo,

# Impersonator Creator Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $ImpersonatorCreatorResourceID,

# Internal Currency Freight Cost
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [double]
    $InternalCurrencyFreight,

# Latest Estimated Arrival Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $LatestEstimatedArrivalDate,

# Payment Term ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity PurchaseOrder -FieldName PaymentTerm -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity PurchaseOrder -FieldName PaymentTerm -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $PaymentTerm,

# Phone
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,25)]
    [string]
    $Phone,

# Purchase For Account ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $PurchaseForAccountID,

# Expected Ship Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ShippingDate,

# Shipping Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $ShippingType,

# Address Line 1
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,128)]
    [string]
    $ShipToAddress1,

# Address Line 2
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,128)]
    [string]
    $ShipToAddress2,

# City
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,30)]
    [string]
    $ShipToCity,

# Addressee Name
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,100)]
    [string]
    $ShipToName,

# Postal Code
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,10)]
    [string]
    $ShipToPostalCode,

# State
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,25)]
    [string]
    $ShipToState,

# Show Each Tax In Tax Group
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [boolean]
    $ShowEachTaxInGroup,

# Show Tax Category
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [boolean]
    $ShowTaxCategory,

# Order Status ID
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity PurchaseOrder -FieldName Status -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity PurchaseOrder -FieldName Status -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $Status,

# Submit Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SubmitDateTime,

# Tax Group ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity PurchaseOrder -FieldName TaxGroup -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity PurchaseOrder -FieldName TaxGroup -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $TaxGroup,

# Use Item Descriptions From
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity PurchaseOrder -FieldName UseItemDescriptionsFrom -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity PurchaseOrder -FieldName UseItemDescriptionsFrom -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $UseItemDescriptionsFrom,

# Vendor Account ID
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int]
    $VendorID,

# Vendor Invoice Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string]
    $VendorInvoiceNumber
  )
 
    begin { 
        $entityName = 'PurchaseOrder'
           
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
        
        $processObject = [Collections.ArrayList]::new()
    }

    process {
    
        if ($InputObject) {
            Write-Verbose -Message ('{0}: Copy Object mode: Setting ID property to zero' -F $MyInvocation.MyCommand.Name)  

            $entityInfo = Get-AtwsFieldInfo -Entity $entityName -EntityInfo
      
            $CopyNo = 1

            foreach ($object in $InputObject) { 
                # Create a new object and copy properties
                $newObject = New-Object -TypeName Autotask.$entityName
        
                # Copy every non readonly property
                $fieldNames = $entityInfo.WritableFields

                if ($PSBoundParameters.ContainsKey('UserDefinedFields')) { 
                    $fieldNames += 'UserDefinedFields' 
                }

                foreach ($field in $fieldNames) { 
                    $newObject.$field = $object.$field 
                }

                if ($newObject -is [Autotask.Ticket]) {
                    Write-Verbose -Message ('{0}: Copy Object mode: Object is a Ticket. Title must be modified to avoid duplicate detection.' -F $MyInvocation.MyCommand.Name)  
                    $title = '{0} (Copy {1})' -F $newObject.Title, $CopyNo
                    $copyNo++
                    $newObject.Title = $title
                }
                [void]$processObject.Add($newObject)
            }   
        }
        else {
            Write-Debug -Message ('{0}: Creating empty [Autotask.{1}]' -F $MyInvocation.MyCommand.Name, $entityName) 
            [void]$processObject.add((New-Object -TypeName Autotask.$entityName))   
        }
        
        # Prepare shouldProcess comments
        $caption = $MyInvocation.MyCommand.Name
        $verboseDescription = '{0}: About to create {1} {2}(s). This action cannot be undone.' -F $caption, $processObject.Count, $entityName
        $verboseWarning = '{0}: About to create {1} {2}(s). This action may not be undoable. Do you want to continue?' -F $caption, $processObject.Count, $entityName

        # Lets don't and say we did!
        if ($PSCmdlet.ShouldProcess($verboseDescription, $verboseWarning, $caption)) { 
            
            # Process parameters and update objects with their values
            $processObject = $processObject | Update-AtwsObjectsWithParameters -BoundParameters $PSBoundParameters -EntityName $EntityName
            
            $result = Set-AtwsData -Entity $processObject -Create
        }
    }

    end {
        Write-Debug -Message ('{0}: End of function, returning {1} {2}(s)' -F $MyInvocation.MyCommand.Name, $result.count, $entityName)
        Return $result
    }

}
