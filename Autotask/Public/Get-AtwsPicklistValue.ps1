﻿<#

    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.

#>

Function Get-AtwsPicklistValue {
    <#
        .SYNOPSIS
            This function gets valid fields for an Autotask Entity
        .DESCRIPTION
            This function gets valid fields for an Autotask Entity
        .INPUTS
            None.
        .OUTPUTS
            [Autotask.Field[]]
        .EXAMPLE
            Get-AtwsFieldInfo -Entity Account
            Gets all valid built-in fields and user defined fields for the Account entity.
  #>
	
    [cmdletbinding(
        DefaultParameterSetName = 'by_Entity'
    )]
    Param
    (
        [Parameter(
            ParameterSetName = 'by_Entity'
        )]
        [Parameter(
            ParameterSetName = 'as_Labels'
        )]
        [Parameter(
            ParameterSetName = 'as_Values'
        )]
        [Alias('UDF')]
        [switch]
        $UserDefinedFields, 
        
        [Parameter(
            ParameterSetName = 'as_Labels'
        )]
        [switch]
        $Label, 

        [Parameter(
            ParameterSetName = 'as_Labels'
        )]
        [switch]
        $Hashtable, 

        [Parameter(
            ParameterSetName = 'as_Values'
        )]
        [switch]
        $Value, 

        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'by_Entity'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'as_Labels'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'as_Values'
        )]

        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter({
            param($Cmd, $Param, $Word, $Ast, $FakeBound)
            $script:FieldInfoCache.keys
        })]
        [string]
        $Entity,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'by_Entity'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'as_Labels'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 2,
            ParameterSetName = 'as_Values'
        )]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter({
            param($Cmd, $Param, $Word, $Ast, $FakeBound)
                if ($FakeBound.UserDefinedFields.IsPresent) { 
                     $script:FieldInfoCache[$fakebound.Entity]['UDFinfo'].keys
                }
                else {
                    $script:FieldInfoCache[$fakebound.Entity]['PickListFields']
                }
        })]
        [string]
        $FieldName,

        [Parameter(
            Mandatory = $false,
            Position = 2,
            ParameterSetName = 'by_Entity'
        )]
        [Parameter(
            Mandatory = $false,
            Position = 2,
            ParameterSetName = 'as_Labels'
        )]
        [Parameter(
            Mandatory = $false,
            Position = 2,
            ParameterSetName = 'as_Values'
        )]
        [string]
        $ParentValue
    )
    
    begin { 
    
        # Enable modern -Debug behavior
        if ($PSCmdlet.MyInvocation.BoundParameters['Debug'].IsPresent) { $DebugPreference = 'Continue' }
    
        Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
    
        # Check if we are connected before trying anything
        if (-not($Script:Atws)) {
            throw [ApplicationException] 'Not connected to Autotask WebAPI. Connect with Connect-AtwsWebAPI. For help use "get-help Connect-AtwsWebAPI".'
            return
        }

        # Prepare an empty container for a result
        $picklistValues = @()
    }
  
    process { 

        
        Write-Verbose -Message ('{0}: Looking up detailed Fieldinfo for entity {1}' -F $MyInvocation.MyCommand.Name, $Entity) 
        
        if ($UserDefinedFields.IsPresent -and $script:FieldInfoCache[$Entity].HasUserDefinedFields) {
            $infoType = 'UDFinfo'
        }
        elseIf ($script:FieldInfoCache[$Entity].HasPicklist) { 
            $infoType = 'FieldInfo'
        }
        else {
            # Nothing to do. Return.
            return
        }

        # Refresh picklists if list is empty
        if ($null -eq $script:FieldInfoCache[$Entity][$infoType][$FieldName]['PicklistValues']) {
            # The API returns all fields anyway, so we do not need to specify field name, but we 
            # need to specify userdefinedfields
            Update-AtwsPicklist -Entity $Entity -UserDefinedFields:$UserDefinedFields.IsPresent
        }

        $picklistValues = $script:FieldInfoCache[$Entity][$infoType][$FieldName]['PicklistValues']

        Write-Verbose -Message ('{0}: Entity {1} has picklists and field {2} has {3} picklist values.' -F $MyInvocation.MyCommand.Name, $Entity, $FieldName, $result.count) 

        if ($picklistValues.count -gt 0 ) {
            if ($picklistValues.keys -contains 'byValue') {
                # No parentfieldname
                $result = switch ($PSCmdlet.ParameterSetName) {
                    'by_Entity' {
                        $picklistValues.byValue
                    }
                    'as_Labels' {
                        if ($Hashtable.IsPresent) { 
                            $picklistValues.byLabel
                        }
                        else { 
                            $picklistValues.byLabel.keys | Sort-Object
                        }
                    }
                    'as_Values' {
                        $picklistValues.byLabel.values | Sort-Object
                    }
                }

            }
            # Take parentvalue into account
            elseIf ($ParentValue) {
                $result = switch ($PSCmdlet.ParameterSetName) {
                    'by_Entity' {
                        $picklistValues[$ParentValue]
                    }
                    'as_Labels' {
                        if ($Hashtable.IsPresent) { 
                            $picklistValues[$ParentValue].byLabel
                        }
                        else { 
                            $picklistValues[$ParentValue].byLabel.keys | Sort-Object
                        }
                    }
                    'as_Values' {
                        $picklistValues[$ParentValue].byLabel.values | Sort-Object
                    }
                }
            }
            # We have a picklist with a parentfield, but no parentvalue. Return 
            # hashtable for by_entity and all labels or keys if either is requested
            else {
                $result = switch ($PSCmdlet.ParameterSetName) {
                    'by_Entity' {
                        $picklistValues
                    }
                    'as_Labels' {
                        if ($Hashtable.IsPresent) { 
                            $picklistValues.Values.byLabel
                        }
                        else { 
                            $picklistValues.Values.byLabel.keys | Sort-Object
                        }
                    }
                    'as_Values' {
                        $picklistValues.Values.byLabel.values | Sort-Object
                    }
                }
            }
        }
    } 
     
    end {

        Write-Debug ('{0}: End of function' -F $MyInvocation.MyCommand.Name)
        
        if ($result.count -gt 0) {
            return $result
        }
        
    }
       
}
