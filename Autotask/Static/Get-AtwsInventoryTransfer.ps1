#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsInventoryTransfer
{


<#
.SYNOPSIS
This function get one or more InventoryTransfer through the Autotask Web Services API.
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


Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.InventoryTransfer[]]. This function outputs the Autotask.InventoryTransfer that was returned by the API.
.EXAMPLE
Get-AtwsInventoryTransfer -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsInventoryTransfer -InventoryTransferName SomeName
Returns the object with InventoryTransferName 'SomeName', if any.
 .EXAMPLE
Get-AtwsInventoryTransfer -InventoryTransferName 'Some Name'
Returns the object with InventoryTransferName 'Some Name', if any.
 .EXAMPLE
Get-AtwsInventoryTransfer -InventoryTransferName 'Some Name' -NotEquals InventoryTransferName
Returns any objects with a InventoryTransferName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsInventoryTransfer -InventoryTransferName SomeName* -Like InventoryTransferName
Returns any object with a InventoryTransferName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsInventoryTransfer -InventoryTransferName SomeName* -NotLike InventoryTransferName
Returns any object with a InventoryTransferName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.

.LINK
New-AtwsInventoryTransfer

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
    [ValidateSet('FromLocationID', 'ProductID', 'ToLocationID', 'TransferByResourceID')]
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
    [string]
    $GetExternalEntityByThisEntityId,

# Return all objects in one query
    [Parameter(
      ParametersetName = 'Get_all'
    )]
    [switch]
    $All,

# Inventory Transfer ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Product ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $ProductID,

# Transfer From Inventory Location ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $FromLocationID,

# Transfer To Inventory Location ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $ToLocationID,

# Quantity Transferred
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[Int][]]
    $QuantityTransferred,

# Transfer By Resource ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $TransferByResourceID,

# Transfer Date
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $TransferDate,

# Notes
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,4000)]
    [string[]]
    $Notes,

# Serial Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string[]]
    $SerialNumber,

# Update Note
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,500)]
    [string[]]
    $UpdateNote,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProductID', 'FromLocationID', 'ToLocationID', 'QuantityTransferred', 'TransferByResourceID', 'TransferDate', 'Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProductID', 'FromLocationID', 'ToLocationID', 'QuantityTransferred', 'TransferByResourceID', 'TransferDate', 'Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProductID', 'FromLocationID', 'ToLocationID', 'QuantityTransferred', 'TransferByResourceID', 'TransferDate', 'Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProductID', 'FromLocationID', 'ToLocationID', 'QuantityTransferred', 'TransferByResourceID', 'TransferDate', 'Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProductID', 'FromLocationID', 'ToLocationID', 'QuantityTransferred', 'TransferByResourceID', 'TransferDate', 'Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProductID', 'FromLocationID', 'ToLocationID', 'QuantityTransferred', 'TransferByResourceID', 'TransferDate', 'Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ProductID', 'FromLocationID', 'ToLocationID', 'QuantityTransferred', 'TransferByResourceID', 'TransferDate', 'Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('Notes', 'SerialNumber', 'UpdateNote')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('TransferDate')]
    [string[]]
    $IsThisDay
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
