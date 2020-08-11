#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function New-AtwsInventoryTransfer
{


<#
.SYNOPSIS
This function creates a new InventoryTransfer through the Autotask Web Services API. All required properties are marked as required parameters to assist you on the command line.
.DESCRIPTION
The function supports all properties of an [Autotask.InventoryTransfer] that can be updated through the Web Services API. The function uses PowerShell parameter validation  and supports IntelliSense for selecting picklist values. Any required paramterer is marked as Mandatory in the PowerShell function to assist you on the command line.

If you need very complicated queries you can write a filter directly and pass it using the -Filter parameter. To get the InventoryTransfer with Id number 0 you could write 'New-AtwsInventoryTransfer -Id 0' or you could write 'New-AtwsInventoryTransfer -Filter {Id -eq 0}.

'New-AtwsInventoryTransfer -Id 0,4' could be written as 'New-AtwsInventoryTransfer -Filter {id -eq 0 -or id -eq 4}'. For simple queries you can see that using parameters is much easier than the -Filter option. But the -Filter option supports an arbitrary sequence of most operators (-eq, -ne, -gt, -ge, -lt, -le, -and, -or, -beginswith, -endswith, -contains, -like, -notlike, -soundslike, -isnotnull, -isnull, -isthisday). As you can group them using parenthesis '()' you can write arbitrarily complex queries with -Filter. 

To create a new InventoryTransfer you need the following required fields:
 -ProductID
 -FromLocationID
 -ToLocationID
 -QuantityTransferred

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.InventoryTransfer]. This function outputs the Autotask.InventoryTransfer that was created by the API.
.EXAMPLE
$result = New-AtwsInventoryTransfer -ProductID [Value] -FromLocationID [Value] -ToLocationID [Value] -QuantityTransferred [Value]
Creates a new [Autotask.InventoryTransfer] through the Web Services API and returns the new object.
 .EXAMPLE
$result = Get-AtwsInventoryTransfer -Id 124 | New-AtwsInventoryTransfer 
Copies [Autotask.InventoryTransfer] by Id 124 to a new object through the Web Services API and returns the new object.
 .EXAMPLE
Get-AtwsInventoryTransfer -Id 124 | New-AtwsInventoryTransfer | Set-AtwsInventoryTransfer -ParameterName <Parameter Value>
Copies [Autotask.InventoryTransfer] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsInventoryTransfer to modify the object.
 .EXAMPLE
$result = Get-AtwsInventoryTransfer -Id 124 | New-AtwsInventoryTransfer | Set-AtwsInventoryTransfer -ParameterName <Parameter Value> -Passthru
Copies [Autotask.InventoryTransfer] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsInventoryTransfer to modify the object and returns the new object.

.LINK
Get-AtwsInventoryTransfer

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
    [Autotask.InventoryTransfer[]]
    $InputObject,

# Transfer Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [datetime]
    $TransferDate,

# Notes
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,4000)]
    [string]
    $Notes,

# Serial Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string]
    $SerialNumber,

# Quantity Transferred
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int]
    $QuantityTransferred,

# Transfer By Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Int]
    $TransferByResourceID,

# Update Note
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,500)]
    [string]
    $UpdateNote,

# Transfer From Inventory Location ID
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [long]
    $FromLocationID,

# Product ID
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [long]
    $ProductID,

# Transfer To Inventory Location ID
    [Parameter(
      Mandatory = $true,
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [long]
    $ToLocationID
  )
 
    begin { 
        $entityName = 'InventoryTransfer'
           
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