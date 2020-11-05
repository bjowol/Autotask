#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function New-AtwsTicket
{


<#
.SYNOPSIS
This function creates a new Ticket through the Autotask Web Services API. All required properties are marked as required parameters to assist you on the command line.
.DESCRIPTION
The function supports all properties of an [Autotask.Ticket] that can be updated through the Web Services API. The function uses PowerShell parameter validation  and supports IntelliSense for selecting picklist values. Any required paramterer is marked as Mandatory in the PowerShell function to assist you on the command line.

If you need very complicated queries you can write a filter directly and pass it using the -Filter parameter. To get the Ticket with Id number 0 you could write 'New-AtwsTicket -Id 0' or you could write 'New-AtwsTicket -Filter {Id -eq 0}.

'New-AtwsTicket -Id 0,4' could be written as 'New-AtwsTicket -Filter {id -eq 0 -or id -eq 4}'. For simple queries you can see that using parameters is much easier than the -Filter option. But the -Filter option supports an arbitrary sequence of most operators (-eq, -ne, -gt, -ge, -lt, -le, -and, -or, -beginswith, -endswith, -contains, -like, -notlike, -soundslike, -isnotnull, -isnull, -isthisday). As you can group them using parenthesis '()' you can write arbitrarily complex queries with -Filter. 

To create a new Ticket you need the following required fields:
 -AccountID
 -Priority
 -Status
 -Title

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.Ticket]. This function outputs the Autotask.Ticket that was created by the API.
.EXAMPLE
$result = New-AtwsTicket -AccountID [Value] -Priority [Value] -Status [Value] -Title [Value]
Creates a new [Autotask.Ticket] through the Web Services API and returns the new object.
 .EXAMPLE
$result = Get-AtwsTicket -Id 124 | New-AtwsTicket 
Copies [Autotask.Ticket] by Id 124 to a new object through the Web Services API and returns the new object.
 .EXAMPLE
Get-AtwsTicket -Id 124 | New-AtwsTicket | Set-AtwsTicket -ParameterName <Parameter Value>
Copies [Autotask.Ticket] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsTicket to modify the object.
 .EXAMPLE
$result = Get-AtwsTicket -Id 124 | New-AtwsTicket | Set-AtwsTicket -ParameterName <Parameter Value> -Passthru
Copies [Autotask.Ticket] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsTicket to modify the object and returns the new object.

.LINK
Get-AtwsTicket
 .LINK
Set-AtwsTicket

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
    [Autotask.Ticket[]]
    $InputObject,

# User defined fields already setup i Autotask
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Alias('UDF')]
    [ValidateNotNullOrEmpty()]
    [Autotask.UserDefinedField[]]
    $UserDefinedFields,

# Account
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int]
    $AccountID,

# Account Physical Location
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $AccountPhysicalLocationID,

# AEM Alert ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string]
    $AEMAlertID,

# Allocation Code Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $AllocationCodeID,

# API Vendor ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName ApiVendorID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName ApiVendorID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $ApiVendorID,

# Resource
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $AssignedResourceID,

# Resource Role Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $AssignedResourceRoleID,

# Business Division Subdivision ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $BusinessDivisionSubdivisionID,

# Change Approval Board ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName ChangeApprovalBoard -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName ChangeApprovalBoard -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $ChangeApprovalBoard,

# Change Approval Status
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName ChangeApprovalStatus -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName ChangeApprovalStatus -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $ChangeApprovalStatus,

# Change Approval Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName ChangeApprovalType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName ChangeApprovalType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $ChangeApprovalType,

# Change Info Field 1
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,8000)]
    [string]
    $ChangeInfoField1,

# Change Info Field 2
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,8000)]
    [string]
    $ChangeInfoField2,

# Change Info Field 3
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,8000)]
    [string]
    $ChangeInfoField3,

# Change Info Field 4
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,8000)]
    [string]
    $ChangeInfoField4,

# Change Info Field 5
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,8000)]
    [string]
    $ChangeInfoField5,

# Ticket Completed By
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $CompletedByResourceID,

# Ticket Date Completed by Complete Project Wizard
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $CompletedDate,

# Ticket Contact
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $ContactID,

# Contract
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $ContractID,

# Contract Service Bundle ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [long]
    $ContractServiceBundleID,

# Contract Service ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [long]
    $ContractServiceID,

# Ticket Creation Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $CreateDate,

# Ticket Creator
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $CreatorResourceID,

# Creator Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName CreatorType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName CreatorType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $CreatorType,

# Current Service Thermometer Rating
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName CurrentServiceThermometerRating -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName CurrentServiceThermometerRating -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $CurrentServiceThermometerRating,

# Ticket Description
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,8000)]
    [string]
    $Description,

# Ticket End Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $DueDateTime,

# Ticket Estimated Hours
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [double]
    $EstimatedHours,

# Ticket External ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string]
    $ExternalID,

# First Response Assigned Resource
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $FirstResponseAssignedResourceID,

# First Response Date Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $FirstResponseDateTime,

# First Response Due Date Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $FirstResponseDueDateTime,

# First Response Initiating Resource
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $FirstResponseInitiatingResourceID,

# Hours to be Scheduled
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [double]
    $HoursToBeScheduled,

# Impersonator Creator Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $ImpersonatorCreatorResourceID,

# Configuration Item
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $InstalledProductID,

# Ticket Issue
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName IssueType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName IssueType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $IssueType,

# Ticket Last Activity Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $LastActivityDate,

# Last Activity Person Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName LastActivityPersonType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName LastActivityPersonType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $LastActivityPersonType,

# Last Edited Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $LastActivityResourceID,

# Last Customer Notification
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $LastCustomerNotificationDateTime,

# Last Customer Visible Activity
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $LastCustomerVisibleActivityDateTime,

# Last Tracked Modification Date Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $LastTrackedModificationDateTime,

# Monitor ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $MonitorID,

# Monitor Type ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName MonitorTypeID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName MonitorTypeID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $MonitorTypeID,

# Opportunity ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $OpportunityId,

# Previous Service Thermometer Rating
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName PreviousServiceThermometerRating -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName PreviousServiceThermometerRating -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $PreviousServiceThermometerRating,

# Ticket Priority
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName Priority -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName Priority -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $Priority,

# Problem Ticket ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $ProblemTicketId,

# Project ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $ProjectID,

# purchase_order_number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string]
    $PurchaseOrderNumber,

# Ticket Department Name OR Ticket Queue Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName QueueID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName QueueID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $QueueID,

# Resolution
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,32000)]
    [string]
    $Resolution,

# Resolution Plan Date Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ResolutionPlanDateTime,

# Resolution Plan Due Date Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ResolutionPlanDueDateTime,

# Resolved Date Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ResolvedDateTime,

# Resolved Due Date Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ResolvedDueDateTime,

# RMA Status
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName RmaStatus -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName RmaStatus -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $RmaStatus,

# RMA Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName RmaType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName RmaType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $RmaType,

# Has Met SLA
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [boolean]
    $ServiceLevelAgreementHasBeenMet,

# Service Level Agreement ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName ServiceLevelAgreementID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName ServiceLevelAgreementID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $ServiceLevelAgreementID,

# Next Service Level Agreement Event in Hours
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [double]
    $ServiceLevelAgreementPausedNextEventHours,

# Service Thermometer Temperature
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $ServiceThermometerTemperature,

# Ticket Source
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName Source -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName Source -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $Source,

# Ticket Status
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName Status -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName Status -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $Status,

# Ticket Subissue Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter( {
        param($Cmd, $Param, $Word, $Ast, $FakeBound)
        if ($fakeBound.IssueType) {
            $parentvalue = $fakeBound.IssueType
            if ([int]$parentValue -eq $parentValue) {
                $parentPicklist = Get-AtwsPicklistValue -Entity Ticket -Field IssueType
                $parentValue = $parentPicklist[$parentValue]
            }      
            $picklists = Get-AtwsPicklistValue -Entity Ticket -FieldName 
            $picklists[$parentValue]['byLabel'].Keys
        }
        else {
            Get-AtwsPicklistValue -Entity Ticket -FieldName  -Label
        }
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName SubIssueType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $SubIssueType,

# Ticket Category
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName TicketCategory -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName TicketCategory -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $TicketCategory,

# Ticket Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string]
    $TicketNumber,

# Ticket Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity Ticket -FieldName TicketType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity Ticket -FieldName TicketType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $TicketType,

# Ticket Title
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,255)]
    [string]
    $Title
  )
 
    begin { 
        $entityName = 'Ticket'
           
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
