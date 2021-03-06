#Requires -Version 4.0
#Version 1.6.10
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Get-AtwsNotificationHistory
{


<#
.SYNOPSIS
This function get one or more NotificationHistory through the Autotask Web Services API.
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

NotificationHistoryTypeID
 

EntityTitle
 

EntityNumber
 

Entities that have fields that refer to the base entity of this CmdLet:


.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.NotificationHistory[]]. This function outputs the Autotask.NotificationHistory that was returned by the API.
.EXAMPLE
Get-AtwsNotificationHistory -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryName SomeName
Returns the object with NotificationHistoryName 'SomeName', if any.
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryName 'Some Name'
Returns the object with NotificationHistoryName 'Some Name', if any.
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryName 'Some Name' -NotEquals NotificationHistoryName
Returns any objects with a NotificationHistoryName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryName SomeName* -Like NotificationHistoryName
Returns any object with a NotificationHistoryName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryName SomeName* -NotLike NotificationHistoryName
Returns any object with a NotificationHistoryName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryTypeID <PickList Label>
Returns any NotificationHistorys with property NotificationHistoryTypeID equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryTypeID <PickList Label> -NotEquals NotificationHistoryTypeID 
Returns any NotificationHistorys with property NotificationHistoryTypeID NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryTypeID <PickList Label1>, <PickList Label2>
Returns any NotificationHistorys with property NotificationHistoryTypeID equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsNotificationHistory -NotificationHistoryTypeID <PickList Label1>, <PickList Label2> -NotEquals NotificationHistoryTypeID
Returns any NotificationHistorys with property NotificationHistoryTypeID NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsNotificationHistory -Id 1234 -NotificationHistoryName SomeName* -NotificationHistoryTypeID <PickList Label1>, <PickList Label2> -Like NotificationHistoryName -NotEquals NotificationHistoryTypeID -GreaterThan Id
An example of a more complex query. This command returns any NotificationHistorys with Id GREATER THAN 1234, a NotificationHistoryName that matches the simple pattern SomeName* AND that has a NotificationHistoryTypeID that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.


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
    [ValidateSet('AccountID', 'InitiatingContactID', 'InitiatingResourceID', 'OpportunityID', 'ProjectID', 'QuoteID', 'TaskID', 'TicketID', 'TimeEntryID')]
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

# ID
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[long][]]
    $id,

# Notification Sent Time
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[datetime][]]
    $NotificationSentTime,

# Template Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,100)]
    [string[]]
    $TemplateName,

# Notification History Type Id
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [string[]]
    $NotificationHistoryTypeID,

# Entity Title
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [string[]]
    $EntityTitle,

# Entity Number
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [string[]]
    $EntityNumber,

# Is Template Deleted
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[boolean][]]
    $IsDeleted,

# Is Template Active
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[boolean][]]
    $IsActive,

# Is Template Job
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Nullable[boolean][]]
    $IsTemplateJob,

# Initiating Resource
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $InitiatingResourceID,

# Initiating Contact
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $InitiatingContactID,

# Recipient Email Address
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,2000)]
    [string[]]
    $RecipientEmailAddress,

# Recipient Display Name
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateLength(0,200)]
    [string[]]
    $RecipientDisplayName,

# Client
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $AccountID,

# Quote
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $QuoteID,

# Opportunity
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $OpportunityID,

# Project
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $ProjectID,

# Task
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $TaskID,

# Ticket
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $TicketID,

# Time Entry
    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [Nullable[long][]]
    $TimeEntryID,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'NotificationSentTime', 'TemplateName', 'NotificationHistoryTypeID', 'EntityTitle', 'EntityNumber', 'IsDeleted', 'IsActive', 'IsTemplateJob', 'InitiatingResourceID', 'InitiatingContactID', 'RecipientEmailAddress', 'RecipientDisplayName', 'AccountID', 'QuoteID', 'OpportunityID', 'ProjectID', 'TaskID', 'TicketID', 'TimeEntryID')]
    [string[]]
    $NotEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'NotificationSentTime', 'TemplateName', 'NotificationHistoryTypeID', 'EntityTitle', 'EntityNumber', 'IsDeleted', 'IsActive', 'IsTemplateJob', 'InitiatingResourceID', 'InitiatingContactID', 'RecipientEmailAddress', 'RecipientDisplayName', 'AccountID', 'QuoteID', 'OpportunityID', 'ProjectID', 'TaskID', 'TicketID', 'TimeEntryID')]
    [string[]]
    $IsNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'NotificationSentTime', 'TemplateName', 'NotificationHistoryTypeID', 'EntityTitle', 'EntityNumber', 'IsDeleted', 'IsActive', 'IsTemplateJob', 'InitiatingResourceID', 'InitiatingContactID', 'RecipientEmailAddress', 'RecipientDisplayName', 'AccountID', 'QuoteID', 'OpportunityID', 'ProjectID', 'TaskID', 'TicketID', 'TimeEntryID')]
    [string[]]
    $IsNotNull,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'NotificationSentTime', 'TemplateName', 'NotificationHistoryTypeID', 'EntityTitle', 'EntityNumber', 'InitiatingResourceID', 'InitiatingContactID', 'RecipientEmailAddress', 'RecipientDisplayName', 'AccountID', 'QuoteID', 'OpportunityID', 'ProjectID', 'TaskID', 'TicketID', 'TimeEntryID')]
    [string[]]
    $GreaterThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'NotificationSentTime', 'TemplateName', 'NotificationHistoryTypeID', 'EntityTitle', 'EntityNumber', 'InitiatingResourceID', 'InitiatingContactID', 'RecipientEmailAddress', 'RecipientDisplayName', 'AccountID', 'QuoteID', 'OpportunityID', 'ProjectID', 'TaskID', 'TicketID', 'TimeEntryID')]
    [string[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'NotificationSentTime', 'TemplateName', 'NotificationHistoryTypeID', 'EntityTitle', 'EntityNumber', 'InitiatingResourceID', 'InitiatingContactID', 'RecipientEmailAddress', 'RecipientDisplayName', 'AccountID', 'QuoteID', 'OpportunityID', 'ProjectID', 'TaskID', 'TicketID', 'TimeEntryID')]
    [string[]]
    $LessThan,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('id', 'NotificationSentTime', 'TemplateName', 'NotificationHistoryTypeID', 'EntityTitle', 'EntityNumber', 'InitiatingResourceID', 'InitiatingContactID', 'RecipientEmailAddress', 'RecipientDisplayName', 'AccountID', 'QuoteID', 'OpportunityID', 'ProjectID', 'TaskID', 'TicketID', 'TimeEntryID')]
    [string[]]
    $LessThanOrEquals,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('TemplateName', 'EntityTitle', 'EntityNumber', 'RecipientEmailAddress', 'RecipientDisplayName')]
    [string[]]
    $Like,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('TemplateName', 'EntityTitle', 'EntityNumber', 'RecipientEmailAddress', 'RecipientDisplayName')]
    [string[]]
    $NotLike,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('TemplateName', 'EntityTitle', 'EntityNumber', 'RecipientEmailAddress', 'RecipientDisplayName')]
    [string[]]
    $BeginsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('TemplateName', 'EntityTitle', 'EntityNumber', 'RecipientEmailAddress', 'RecipientDisplayName')]
    [string[]]
    $EndsWith,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('TemplateName', 'EntityTitle', 'EntityNumber', 'RecipientEmailAddress', 'RecipientDisplayName')]
    [string[]]
    $Contains,

    [Parameter(
      ParametersetName = 'By_parameters'
    )]
    [ValidateSet('NotificationSentTime')]
    [string[]]
    $IsThisDay
  )

    begin { 
        $entityName = 'NotificationHistory'
    
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
