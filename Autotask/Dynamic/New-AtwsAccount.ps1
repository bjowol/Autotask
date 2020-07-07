#Requires -Version 4.0
#Version 1.6.7
<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function New-AtwsAccount
{


<#
.SYNOPSIS
This function creates a new Account through the Autotask Web Services API. All required properties are marked as required parameters to assist you on the command line.
.DESCRIPTION
The function supports all properties of an [Autotask.Account] that can be updated through the Web Services API. The function uses PowerShell parameter validation  and supports IntelliSense for selecting picklist values. Any required paramterer is marked as Mandatory in the PowerShell function to assist you on the command line.

If you need very complicated queries you can write a filter directly and pass it using the -Filter parameter. To get the Account with Id number 0 you could write 'New-AtwsAccount -Id 0' or you could write 'New-AtwsAccount -Filter {Id -eq 0}.

'New-AtwsAccount -Id 0,4' could be written as 'New-AtwsAccount -Filter {id -eq 0 -or id -eq 4}'. For simple queries you can see that using parameters is much easier than the -Filter option. But the -Filter option supports an arbitrary sequence of most operators (-eq, -ne, -gt, -ge, -lt, -le, -and, -or, -beginswith, -endswith, -contains, -like, -notlike, -soundslike, -isnotnull, -isnull, -isthisday). As you can group them using parenthesis '()' you can write arbitrarily complex queries with -Filter. 

To create a new Account you need the following required fields:
 -AccountName
 -Phone
 -AccountType
 -OwnerResourceID

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
[Autotask.Account]. This function outputs the Autotask.Account that was created by the API.
.EXAMPLE
$result = New-AtwsAccount -AccountName [Value] -Phone [Value] -AccountType [Value] -OwnerResourceID [Value]
Creates a new [Autotask.Account] through the Web Services API and returns the new object.
 .EXAMPLE
$result = Get-AtwsAccount -Id 124 | New-AtwsAccount 
Copies [Autotask.Account] by Id 124 to a new object through the Web Services API and returns the new object.
 .EXAMPLE
Get-AtwsAccount -Id 124 | New-AtwsAccount | Set-AtwsAccount -ParameterName <Parameter Value>
Copies [Autotask.Account] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsAccount to modify the object.
 .EXAMPLE
$result = Get-AtwsAccount -Id 124 | New-AtwsAccount | Set-AtwsAccount -ParameterName <Parameter Value> -Passthru
Copies [Autotask.Account] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsAccount to modify the object and returns the new object.

.LINK
Get-AtwsAccount
 .LINK
Set-AtwsAccount

#>

  [CmdLetBinding(SupportsShouldProcess = $true, DefaultParameterSetName='By_parameters', ConfirmImpact='Low')]
  Param()
 
    dynamicParam {
      $entityName = 'Account'
      $entity = Get-AtwsFieldInfo -Entity $entityName -EntityInfo
      $fieldInfo = Get-AtwsFieldInfo -Entity $entityName
      Get-AtwsDynamicParameterDefinition -Verb 'New' -Entity $entity -FieldInfo $fieldInfo
    } 

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
