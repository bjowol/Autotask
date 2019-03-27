﻿<#

    .COPYRIGHT
    Copyright (c) Office Center Hønefoss AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/officecenter/Autotask/blob/master/LICENSE.md for license information.

#>

Function Set-AtwsData 
{
  <#
      .SYNOPSIS
      This function updates one or more Autotask entities with new or modified properties.
      .DESCRIPTION
      This function updates one or more Autotask entities with new or modified properties
      .INPUTS
      Autotask.Entity[]. One or more Autotask entities to update
      .OUTPUTS
      Autotask.Entity[]. The updated entities are re-downloaded from the API.
      .EXAMPLE
      Set-AtwsData -Entity $Entity
      Passes all Autotask entities in $Entity to the Autotask webservices API
      .NOTES
      NAME: Set-AtwsData
      .LINK
      Get-AtwsData
      New-AtwsData
      Remove-AtwsData
  #>
 
  [cmdletbinding(
      SupportsShouldProcess = $True,
      ConfirmImpact = 'Medium'
  )]
  [OutputType([PSObject[]])]
  param
  (
    [Parameter(
        Mandatory = $True,
        ValueFromPipeline = $True
    )]
    [ValidateNotNullOrEmpty()]
    [PSObject[]]
    $Entity
  )
    
    
  Begin
  { 
    # Enable modern -Debug behavior
    If ($PSCmdlet.MyInvocation.BoundParameters['Debug'].IsPresent) {$DebugPreference = 'Continue'}
    
    Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
    
    If (-not($Script:Atws.Url))
    {
      Throw [ApplicationException] 'Not connected to Autotask WebAPI. Re-import module with valid credentials.'
    }
    
    $EndResult = @()
        
  }
  
  Process
  { 
    Write-Verbose ('{0}: Updating Autotask {1} with id {2}' -F $MyInvocation.MyCommand.Name, $Entity[0].GetType().Name, $($Entity.id -join ', '))


    $Caption = 'Set-Atws{0}' -F $Entity[0].GetType().Name
    $VerboseDescrition = '{0}: About to modify {1} {2}(s). This action cannot be undone.' -F $Caption, $Entity.Count, $Entity[0].GetType().name
    $VerboseWarning = '{0}: About to modify {1} {2}(s). This action cannot be undone. Do you want to continue?' -F $Caption, $Entity.Count, $Entity[0].GetType().Name

    If ($PSCmdlet.ShouldProcess($VerboseDescrition, $VerboseWarning, $Caption))
    { 
      # update() function can take up to 200 objects at a time
      For ($i = 0; $i -lt $Entity.count; $i += 200) 
      {
        $j = $i + 199
        If ($j -gt ($Entity.count - 1)) 
        {
          $j = $Entity.count - 1
        } 
        Write-Debug -Message ('{0}: Creating chunk from index {1} to index {2}' -F $MyInvocation.MyCommand.Name, $i, $j)        
        
        $Result = $atws.update($Entity[$i .. $j])
      }
    
    
      If ($Result.Errors.Count -eq 0)
      {
        $EndResult += $Result.EntityResults
      }
      Else
      {
        Foreach ($AtwsError in $Result.Errors)
        {
          Write-Error $AtwsError.Message
        }
      }
    }
  }
  End 
  {
    Write-Debug ('{0}: End of function' -F $MyInvocation.MyCommand.Name) 
    Return $EndResult  
        
  }
}
