<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md for license information.
#>
Function Initialize-AtwsRamCache {
    <#
            .SYNOPSIS
                This function reads the cachefile into memory.
            .DESCRIPTION
                This function determines the correct path to a cache file and imports it.
                Then it creates a shadow cache for the current Autotask tenant.
            .INPUTS
                Nothing.
            .OUTPUTS
                Nothing, but the cache property of the SOAP Client object is filled.
            .EXAMPLE
                Initialize-AtwsRamCache
                Loads the cache from disk
            .NOTES
                NAME: Initialize-AtwsRamCache
            .LINK
    #>
    [CmdLetBinding()]
  
    Param()

    begin {
        Write-Verbose -Message ('{0}: trying to determine correct location for dynamic module cache.' -F $MyInvocation.MyCommand.Name)    
    
        # Get the current module name
        $myModule = (Get-Command -Name $MyInvocation.MyCommand.Name).Module
    
        $cacheFile = 'AutotaskFieldInfoCache.xml'
    
        # Use join-path to be platform agnostic on slashes in paths
        $centralCache = Join-Path $(Join-Path $myModule.ModuleBase 'Private') $cacheFile

        Write-Verbose -Message ('{0}: Module cache location is {1}' -F $MyInvocation.MyCommand.Name, $centralCache)  
        
    }
  
    process {
        # Keeping old cache code. Will use it to clean up from earlier module versions
        if ($false) { 
            # On Windows we store the cache in the WindowsPowerhell folder in My documents
            # On macOS and Linux we use a dot-folder in the users $HOME folder as is customary
            if ([Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([Runtime.InteropServices.OSPlatform]::Windows)) {  
                $PersonalCacheDir = Join-Path $([environment]::GetFolderPath('MyDocuments')) 'WindowsPowershell\Cache' 
            }
            else {
                $PersonalCacheDir = Join-Path $([environment]::GetFolderPath('MyDocuments')) '.config\powershell\atwsCache' 
            }
        }
        else {
            Write-Verbose -Message ('{0}: Initializing memory-only cache with data supplied with module ({1}).' -F $MyInvocation.MyCommand.Name, $centralCache)
            
            # Initialize memory only cache from module directory
            $Script:Atws.Cache = Import-Clixml -Path $centralCache      
        }
    
        # We must be connected to know the customer identity number
        if ($Script:Atws.CI) {
            # If the current connection is for a new Autotask tenant, copy the blank 
            # cache from the included pre-cache
            if (-not ($Script:Atws.Cache.ContainsKey($Script:Atws.CI))) {
                Write-Debug -Message ('{0}: Cache does not contain information about Autotask tenant {1}. Initializing.' -F $MyInvocation.MyCommand.Name, $Script:Atws.CI )
                
                # Create a cache object to store API version along with the cache
                $Script:Atws.Cache[$Script:Atws.CI] = New-Object -TypeName PSObject -Property @{
                    ApiVersion    = $Script:Atws.Cache['00'].ApiVersion
                    ModuleVersion = [Version]$My.ModuleVersion
                }
                # Use Add-Member on the Hashtable, or the propertyvalue will be set to typename only
                # Copy the hashtable to a new object. We do NOT want a referenced copy!
                $newHashTable = Copy-PSObject -InputObject $Script:Atws.Cache['00'].FieldInfoCache
                Add-Member -InputObject $Script:Atws.Cache[$Script:Atws.CI] -MemberType NoteProperty -Name FieldInfoCache -Value $newHashTable

            }

            # Initialize the $Script:FieldInfoCache shorthand 
            $Script:FieldInfoCache = $Script:Atws.Cache[$Script:Atws.CI].FieldInfoCache
      
      
            # If the API version has been changed at the Autotask end we unfortunately have to reload all
            # entities from scratch
            $currentApiVersion = $Script:Atws.GetWsdlVersion($Script:Atws.IntegrationsValue)
            if ($Script:Atws.Cache[$Script:Atws.CI].ApiVersion -ne $currentApiVersion -or [Version]$My.ModuleVersion -ne $Script:Atws.Cache[$Script:Atws.CI].ModuleVersion) {
        
                # Call the import-everything function
                Update-AtwsRamCache
        
            }
      
        }
        else {
            Write-Debug -Message ('{0}: No connection to Autotask or running with -NoDiskCache. Loading using module supplied data for Get-AtwsFieldInfo.' -F $MyInvocation.MyCommand.Name )
          
            # Initialize the $Script:FieldInfoCache shorthand for base entity info
            $Script:FieldInfoCache = $Script:Atws.Cache['00'].FieldInfoCache
        }
    }
  
    end {
        Write-Verbose ('{0}: End of function' -F $MyInvocation.MyCommand.Name)    
    }
}
