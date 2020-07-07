#Requires -Version 4.0
#Version 1.6.7
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsChecklistLibrary
{


<#
.SYNOPSIS
This function get one or more ChecklistLibrary through the Autotask Web Services API.
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

EntityType
 

Entities that have fields that refer to the base entity of this CmdLet:

ChecklistLibraryChecklistItem
 TicketChecklistLibrary

.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.ChecklistLibrary[]]. This function outputs the Autotask.ChecklistLibrary that was returned by the API.
.EXAMPLE
Get-AtwsChecklistLibrary -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsChecklistLibrary -ChecklistLibraryName SomeName
Returns the object with ChecklistLibraryName 'SomeName', if any.
 .EXAMPLE
Get-AtwsChecklistLibrary -ChecklistLibraryName 'Some Name'
Returns the object with ChecklistLibraryName 'Some Name', if any.
 .EXAMPLE
Get-AtwsChecklistLibrary -ChecklistLibraryName 'Some Name' -NotEquals ChecklistLibraryName
Returns any objects with a ChecklistLibraryName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsChecklistLibrary -ChecklistLibraryName SomeName* -Like ChecklistLibraryName
Returns any object with a ChecklistLibraryName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsChecklistLibrary -ChecklistLibraryName SomeName* -NotLike ChecklistLibraryName
Returns any object with a ChecklistLibraryName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsChecklistLibrary -E <PickList Label>
Returns any ChecklistLibrarys with property E equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsChecklistLibrary -E <PickList Label> -NotEquals E 
Returns any ChecklistLibrarys with property E NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsChecklistLibrary -E <PickList Label1>, <PickList Label2>
Returns any ChecklistLibrarys with property E equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsChecklistLibrary -E <PickList Label1>, <PickList Label2> -NotEquals E
Returns any ChecklistLibrarys with property E NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsChecklistLibrary -Id 1234 -ChecklistLibraryName SomeName* -E <PickList Label1>, <PickList Label2> -Like ChecklistLibraryName -NotEquals E -GreaterThan Id
An example of a more complex query. This command returns any ChecklistLibrarys with Id GREATER THAN 1234, a ChecklistLibraryName that matches the simple pattern SomeName* AND that has a E that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-AtwsChecklistLibrary
 .LINK
Remove-AtwsChecklistLibrary
 .LINK
Set-AtwsChecklistLibrary

#>

  [CmdLetBinding(SupportsShouldProcess = $true, DefaultParameterSetName='Filter', ConfirmImpact='None')]
  Param()

    dynamicParam {
      $entityName = 'ChecklistLibrary'
      $entity = Get-AtwsFieldInfo -Entity $entityName -EntityInfo
      $fieldInfo = Get-AtwsFieldInfo -Entity $entityName
      Get-AtwsDynamicParameterDefinition -Verb 'Get' -Entity $entity -FieldInfo $fieldInfo
    }  

    begin { 
        $entityName = 'ChecklistLibrary'
    
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
