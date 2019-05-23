﻿#Requires -Version 4.0
#Version 1.6.2.10
<#

.COPYRIGHT
Copyright (c) Office Center Hønefoss AS. All rights reserved. Based on code from Jan Egil Ring (Crayon). Licensed under the MIT license.
See https://github.com/officecenter/Autotask/blob/master/LICENSE.md for license information.

#>
Function New-AtwsHolidaySet
{


<#
.SYNOPSIS
This function creates a new HolidaySet through the Autotask Web Services API. All required properties are marked as required parameters to assist you on the command line.
.DESCRIPTION
The function supports all properties of an [Autotask.HolidaySet] that can be updated through the Web Services API. The function uses PowerShell parameter validation  and supports IntelliSense for selecting picklist values. Any required paramterer is marked as Mandatory in the PowerShell function to assist you on the command line.

If you need very complicated queries you can write a filter directly and pass it using the -Filter parameter. To get the HolidaySet with Id number 0 you could write 'New-AtwsHolidaySet -Id 0' or you could write 'New-AtwsHolidaySet -Filter {Id -eq 0}.

'New-AtwsHolidaySet -Id 0,4' could be written as 'New-AtwsHolidaySet -Filter {id -eq 0 -or id -eq 4}'. For simple queries you can see that using parameters is much easier than the -Filter option. But the -Filter option supports an arbitrary sequence of most operators (-eq, -ne, -gt, -ge, -lt, -le, -and, -or, -beginswith, -endswith, -contains, -like, -notlike, -soundslike, -isnotnull, -isnull, -isthisday). As you can group them using parenthesis '()' you can write arbitrarily complex queries with -Filter. 

To create a new HolidaySet you need the following required fields:
 -HolidaySetName

Entities that have fields that refer to the base entity of this CmdLet:

BusinessLocation
 Holiday

.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.HolidaySet]. This function outputs the Autotask.HolidaySet that was created by the API.
.EXAMPLE
$Result = New-AtwsHolidaySet -HolidaySetName [Value]
Creates a new [Autotask.HolidaySet] through the Web Services API and returns the new object.
 .EXAMPLE
$Result = Get-AtwsHolidaySet -Id 124 | New-AtwsHolidaySet 
Copies [Autotask.HolidaySet] by Id 124 to a new object through the Web Services API and returns the new object.
 .EXAMPLE
Get-AtwsHolidaySet -Id 124 | New-AtwsHolidaySet | Set-AtwsHolidaySet -ParameterName <Parameter Value>
Copies [Autotask.HolidaySet] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsHolidaySet to modify the object.
 .EXAMPLE
$Result = Get-AtwsHolidaySet -Id 124 | New-AtwsHolidaySet | Set-AtwsHolidaySet -ParameterName <Parameter Value> -Passthru
Copies [Autotask.HolidaySet] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsHolidaySet to modify the object and returns the new object.

.LINK
Remove-AtwsHolidaySet
 .LINK
Get-AtwsHolidaySet
 .LINK
Set-AtwsHolidaySet

#>

  [CmdLetBinding(DefaultParameterSetName='By_parameters', ConfirmImpact='Low')]
  Param
  (
# An array of objects to create
    [Parameter(
      ParameterSetName = 'Input_Object',
      ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [Autotask.HolidaySet[]]
    $InputObject,

# Holiday Set Name
    [Parameter(
      Mandatory = $true,
      ParameterSetName = 'By_parameters'
    )]
    [Alias('Name')]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,64)]
    [string]
    $HolidaySetName,

# Holiday Set Description
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,512)]
    [string]
    $HolidaySetDescription
  )
 
  Begin
  { 
    $EntityName = 'HolidaySet'
           
    # Enable modern -Debug behavior
    If ($PSCmdlet.MyInvocation.BoundParameters['Debug'].IsPresent) {$DebugPreference = 'Continue'}
    
    Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
    
    $ProcessObject = @()
  }

  Process
  {
    $Fields = Get-AtwsFieldInfo -Entity $EntityName
    
    If ($InputObject)
    {
      Write-Verbose ('{0}: Copy Object mode: Setting ID property to zero' -F $MyInvocation.MyCommand.Name)  
      
      $CopyNo = 1

      Foreach ($Object in $InputObject) 
      { 
        # Create a new object and copy properties
        $NewObject = New-Object Autotask.$EntityName
        
        # Copy every non readonly property
        $FieldNames = $Fields.Where({$_.Name -ne 'id'}).Name
        If ($PSBoundParameters.ContainsKey('UserDefinedFields')) {
          $FieldNames += 'UserDefinedFields'
        }
        Foreach ($Field in $FieldNames)
        {
          $NewObject.$Field = $Object.$Field
        }
        If ($NewObject -is [Autotask.Ticket])
        {
          Write-Verbose ('{0}: Copy Object mode: Object is a Ticket. Title must be modified to avoid duplicate detection.' -F $MyInvocation.MyCommand.Name)  
          $Title = '{0} (Copy {1})' -F $NewObject.Title, $CopyNo
          $CopyNo++
          $NewObject.Title = $Title
        }
        $ProcessObject += $NewObject
      }   
    }
    Else
    {
      Write-Debug ('{0}: Creating empty [Autotask.{1}]' -F $MyInvocation.MyCommand.Name, $EntityName) 
      $ProcessObject += New-Object Autotask.$EntityName    
    }
    
    Foreach ($Parameter in $PSBoundParameters.GetEnumerator())
    {
      $Field = $Fields | Where-Object {$_.Name -eq $Parameter.Key}
      If ($Field -or $Parameter.Key -eq 'UserDefinedFields')
      { 
        If ($Field.IsPickList)
        {
          If($Field.PickListParentValueField)
          {
            $ParentField = $Fields.Where{$_.Name -eq $Field.PickListParentValueField}
            $ParentLabel = $PSBoundParameters.$($ParentField.Name)
            $ParentValue = $ParentField.PickListValues | Where-Object {$_.Label -eq $ParentLabel}
            $PickListValue = $Field.PickListValues | Where-Object {$_.Label -eq $Parameter.Value -and $_.ParentValue -eq $ParentValue.Value}                
          }
          Else 
          { 
            $PickListValue = $Field.PickListValues | Where-Object {$_.Label -eq $Parameter.Value}
          }
          $Value = $PickListValue.Value
        }
        Else
        {
          $Value = $Parameter.Value
        } 

        Foreach ($Object in $ProcessObject) 
        { 
          $Object.$($Parameter.Key) = $Value
        }
      }
    }    

    $Result = New-AtwsData -Entity $ProcessObject
  }

  End
  {
    Write-Debug ('{0}: End of function, returning {1} {2}(s)' -F $MyInvocation.MyCommand.Name, $Result.count, $EntityName)
    Return $Result
  }

}
