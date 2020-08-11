#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function New-AtwsBusinessLocation
{


<#
.SYNOPSIS
This function creates a new BusinessLocation through the Autotask Web Services API. All required properties are marked as required parameters to assist you on the command line.
.DESCRIPTION
The function supports all properties of an [Autotask.BusinessLocation] that can be updated through the Web Services API. The function uses PowerShell parameter validation  and supports IntelliSense for selecting picklist values. Any required paramterer is marked as Mandatory in the PowerShell function to assist you on the command line.

If you need very complicated queries you can write a filter directly and pass it using the -Filter parameter. To get the BusinessLocation with Id number 0 you could write 'New-AtwsBusinessLocation -Id 0' or you could write 'New-AtwsBusinessLocation -Filter {Id -eq 0}.

'New-AtwsBusinessLocation -Id 0,4' could be written as 'New-AtwsBusinessLocation -Filter {id -eq 0 -or id -eq 4}'. For simple queries you can see that using parameters is much easier than the -Filter option. But the -Filter option supports an arbitrary sequence of most operators (-eq, -ne, -gt, -ge, -lt, -le, -and, -or, -beginswith, -endswith, -contains, -like, -notlike, -soundslike, -isnotnull, -isnull, -isthisday). As you can group them using parenthesis '()' you can write arbitrarily complex queries with -Filter. 

To create a new BusinessLocation you need the following required fields:
 -Name
 -DateFormat
 -TimeFormat
 -NumberFormat
 -TimeZoneID

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.BusinessLocation]. This function outputs the Autotask.BusinessLocation that was created by the API.
.EXAMPLE
$result = New-AtwsBusinessLocation -Name [Value] -DateFormat [Value] -TimeFormat [Value] -NumberFormat [Value] -TimeZoneID [Value]
Creates a new [Autotask.BusinessLocation] through the Web Services API and returns the new object.
 .EXAMPLE
$result = Get-AtwsBusinessLocation -Id 124 | New-AtwsBusinessLocation 
Copies [Autotask.BusinessLocation] by Id 124 to a new object through the Web Services API and returns the new object.
 .EXAMPLE
Get-AtwsBusinessLocation -Id 124 | New-AtwsBusinessLocation | Set-AtwsBusinessLocation -ParameterName <Parameter Value>
Copies [Autotask.BusinessLocation] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsBusinessLocation to modify the object.
 .EXAMPLE
$result = Get-AtwsBusinessLocation -Id 124 | New-AtwsBusinessLocation | Set-AtwsBusinessLocation -ParameterName <Parameter Value> -Passthru
Copies [Autotask.BusinessLocation] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsBusinessLocation to modify the object and returns the new object.

.LINK
Get-AtwsBusinessLocation
 .LINK
Set-AtwsBusinessLocation

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
    [Autotask.BusinessLocation[]]
    $InputObject,

# Address1
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string]
    $Address1,

# Holiday Hours Type
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity BusinessLocation -FieldName HolidayHoursType -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity BusinessLocation -FieldName HolidayHoursType -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $HolidayHoursType,

# ThursdayBusinessHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ThursdayBusinessHoursEndTime,

# State
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,25)]
    [string]
    $State,

# Holiday Extended Hours End Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $HolidayExtendedHoursEndTime,

# ThursdayBusinessHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ThursdayBusinessHoursStartTime,

# Address2
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string]
    $Address2,

# Default
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [boolean]
    $Default,

# SaturdayBusinessHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SaturdayBusinessHoursEndTime,

# City
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,50)]
    [string]
    $City,

# SaturdayExtendedHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SaturdayExtendedHoursEndTime,

# FridayBusinessHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $FridayBusinessHoursStartTime,

# ThursdayExtendedHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ThursdayExtendedHoursEndTime,

# TuesdayBusinessHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $TuesdayBusinessHoursStartTime,

# Time Format
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity BusinessLocation -FieldName TimeFormat -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity BusinessLocation -FieldName TimeFormat -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $TimeFormat,

# Additional Address Info
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string]
    $AdditionalAddressInfo,

# MondayBusinessHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $MondayBusinessHoursEndTime,

# TuesdayBusinessHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $TuesdayBusinessHoursEndTime,

# MondayExtendedHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $MondayExtendedHoursEndTime,

# SaturdayExtendedHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SaturdayExtendedHoursStartTime,

# First Day Of Week
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity BusinessLocation -FieldName FirstDayOfWeek -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity BusinessLocation -FieldName FirstDayOfWeek -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $FirstDayOfWeek,

# Holiday Extended Hours Start Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $HolidayExtendedHoursStartTime,

# WednesdayBusinessHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $WednesdayBusinessHoursStartTime,

# MondayBusinessHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $MondayBusinessHoursStartTime,

# FridayExtendedHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $FridayExtendedHoursStartTime,

# Holiday Hours Start Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $HolidayHoursStartTime,

# No Hours On Holidays
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [boolean]
    $NoHoursOnHolidays,

# SundayBusinessHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SundayBusinessHoursEndTime,

# Time Zone ID
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity BusinessLocation -FieldName TimeZoneID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity BusinessLocation -FieldName TimeZoneID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $TimeZoneID,

# Holiday Hours End Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $HolidayHoursEndTime,

# WednesdayExtendedHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $WednesdayExtendedHoursEndTime,

# FridayExtendedHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $FridayExtendedHoursEndTime,

# Name
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,100)]
    [string]
    $Name,

# Country ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $CountryID,

# MondayExtendedHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $MondayExtendedHoursStartTime,

# SaturdayBusinessHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SaturdayBusinessHoursStartTime,

# TuesdayExtendedHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $TuesdayExtendedHoursStartTime,

# SundayExtendedHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SundayExtendedHoursStartTime,

# WednesdayBusinessHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $WednesdayBusinessHoursEndTime,

# Holiday Set ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $HolidaySetID,

# ThursdayExtendedHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $ThursdayExtendedHoursStartTime,

# FridayBusinessHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $FridayBusinessHoursEndTime,

# Date Format
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity BusinessLocation -FieldName DateFormat -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity BusinessLocation -FieldName DateFormat -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $DateFormat,

# SundayBusinessHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SundayBusinessHoursStartTime,

# Number Format
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity BusinessLocation -FieldName NumberFormat -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity BusinessLocation -FieldName NumberFormat -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string]
    $NumberFormat,

# SundayExtendedHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $SundayExtendedHoursEndTime,

# Postal Code
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,20)]
    [string]
    $PostalCode,

# WednesdayExtendedHoursStartTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $WednesdayExtendedHoursStartTime,

# TuesdayExtendedHoursEndTime
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $TuesdayExtendedHoursEndTime
  )
 
    begin { 
        $entityName = 'BusinessLocation'
           
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
        
        $processObject = @()
    }

    process {
    
        if ($InputObject) {
            Write-Verbose -Message ('{0}: Copy Object mode: Setting ID property to zero' -F $MyInvocation.MyCommand.Name)  

            $fields = Get-AtwsFieldInfo -Entity $entityName
      
            $CopyNo = 1

            foreach ($object in $InputObject) { 
                # Create a new object and copy properties
                $newObject = New-Object -TypeName Autotask.$entityName
        
                # Copy every non readonly property
                $fieldNames = $fields.Where( { $_.Name -ne 'id' }).Name

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
                $processObject += $newObject
            }   
        }
        else {
            Write-Debug -Message ('{0}: Creating empty [Autotask.{1}]' -F $MyInvocation.MyCommand.Name, $entityName) 
            $processObject += New-Object -TypeName Autotask.$entityName    
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
