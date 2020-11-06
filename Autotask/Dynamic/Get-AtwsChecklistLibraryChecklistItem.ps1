#Requires -Version 5.0
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsChecklistLibraryChecklistItem
{


<#
.SYNOPSIS
This function get one or more ChecklistLibraryChecklistItem through the Autotask Web Services API.
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

KnowledgebaseArticleID
 

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.ChecklistLibraryChecklistItem[]]. This function outputs the Autotask.ChecklistLibraryChecklistItem that was returned by the API.
.EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -ChecklistLibraryChecklistItemName SomeName
Returns the object with ChecklistLibraryChecklistItemName 'SomeName', if any.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -ChecklistLibraryChecklistItemName 'Some Name'
Returns the object with ChecklistLibraryChecklistItemName 'Some Name', if any.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -ChecklistLibraryChecklistItemName 'Some Name' -NotEquals ChecklistLibraryChecklistItemName
Returns any objects with a ChecklistLibraryChecklistItemName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -ChecklistLibraryChecklistItemName SomeName* -Like ChecklistLibraryChecklistItemName
Returns any object with a ChecklistLibraryChecklistItemName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -ChecklistLibraryChecklistItemName SomeName* -NotLike ChecklistLibraryChecklistItemName
Returns any object with a ChecklistLibraryChecklistItemName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -K <PickList Label>
Returns any ChecklistLibraryChecklistItems with property K equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -K <PickList Label> -NotEquals K 
Returns any ChecklistLibraryChecklistItems with property K NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -K <PickList Label1>, <PickList Label2>
Returns any ChecklistLibraryChecklistItems with property K equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -K <PickList Label1>, <PickList Label2> -NotEquals K
Returns any ChecklistLibraryChecklistItems with property K NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsChecklistLibraryChecklistItem -Id 1234 -ChecklistLibraryChecklistItemName SomeName* -K <PickList Label1>, <PickList Label2> -Like ChecklistLibraryChecklistItemName -NotEquals K -GreaterThan Id
An example of a more complex query. This command returns any ChecklistLibraryChecklistItems with Id GREATER THAN 1234, a ChecklistLibraryChecklistItemName that matches the simple pattern SomeName* AND that has a K that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-AtwsChecklistLibraryChecklistItem
 .LINK
Remove-AtwsChecklistLibraryChecklistItem
 .LINK
Set-AtwsChecklistLibraryChecklistItem

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
    [ValidateSet('ChecklistLibraryID')]
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

# Checklist Library Checklist Item ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(0,255)]
    [string[]]
    $ItemName,

# Important
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[boolean][]]
    $Important,

# Knowledgebase Article ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ArgumentCompleter({
      param($Cmd, $Param, $Word, $Ast, $FakeBound)
      Get-AtwsPicklistValue -Entity ChecklistLibraryChecklistItem -FieldName KnowledgebaseArticleID -Label
    })]
    [ValidateScript({
      $set = Get-AtwsPicklistValue -Entity ChecklistLibraryChecklistItem -FieldName KnowledgebaseArticleID -Label
      if ($_ -in $set) { return $true}
      else {
        Write-Warning ('{0} is not one of {1}' -f $_, ($set -join ', '))
        Return $false
      }
    })]
    [string[]]
    $KnowledgebaseArticleID,

# Position
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[Int][]]
    $Position,

# Checklist Library ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[Int][]]
    $ChecklistLibraryID,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ItemName', 'Important', 'KnowledgebaseArticleID', 'Position', 'ChecklistLibraryID')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ItemName', 'Important', 'KnowledgebaseArticleID', 'Position', 'ChecklistLibraryID')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ItemName', 'Important', 'KnowledgebaseArticleID', 'Position', 'ChecklistLibraryID')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ItemName', 'KnowledgebaseArticleID', 'Position', 'ChecklistLibraryID')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ItemName', 'KnowledgebaseArticleID', 'Position', 'ChecklistLibraryID')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ItemName', 'KnowledgebaseArticleID', 'Position', 'ChecklistLibraryID')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'ItemName', 'KnowledgebaseArticleID', 'Position', 'ChecklistLibraryID')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('ItemName')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'ChecklistLibraryChecklistItem'
    
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
