<#
    .COPYRIGHT
    Copyright (c) ECIT Solutions AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/ecitsolutions/Autotask/blob/master/LICENSE.md  for license information.
#>

[CmdletBinding(
    PositionalBinding = $false
)]
Param(
    [Parameter(
        Position = 0
    )]
    [pscustomobject]
    $Credential,
    
    [Parameter(
        Position = 1
    )]
    [string]
    $ApiTrackingIdentifier, 

    [Parameter(
        Position = 2,
        ValueFromRemainingArguments = $true
    )]
    [string[]]
    $entityName
)

Write-Debug ('{0}: Start of module import' -F $MyInvocation.MyCommand.Name)

# Explicit loading of namespace
#$namespace = 'Autotask'
#. ([scriptblock]::Create("using namespace $namespace"))

# Special consideration for -Verbose, as there is no $PSCmdLet context to check if Import-Module was called using -Verbose
# and $VerbosePreference is not inherited from Import-Module for some reason.

# Remove comments
$parentCommand = ($MyInvocation.Line -split '#')[0]

# Store Previous preference
$oldVerbosePreference = $VerbosePreference
if ($parentCommand -like '*-Verbose*') {
    Write-Debug ('{0}: Verbose preference detected. Verbose messages ON.' -F $MyInvocation.MyCommand.Name)
    $VerbosePreference = 'Continue'
}
$oldDebugPreference = $DebugPreference
if ($parentCommand -like '*-Debug*') {
    Write-Debug ('{0}: Debug preference detected. Debug messages ON.' -F $MyInvocation.MyCommand.Name)
    $DebugPreference = 'Continue'
}

# Read our own manifest to access configuration data
$manifestFileName = $MyInvocation.MyCommand.Name -replace 'pdm1$', 'psd1'
$manifestDirectory = Split-Path $MyInvocation.MyCommand.Path -Parent

Write-Debug ('{0}: Loading Manifest file {1} from {2}' -F $MyInvocation.MyCommand.Name, $manifestFileName, $manifestDirectory)

Import-LocalizedData -BindingVariable My -FileName $manifestFileName -BaseDirectory $manifestDirectory

# Add module path to manifest variable
$My['ModuleBase'] = $manifestDirectory

# Get all function files as file objects
# Private functions can only be called internally in other functions in the module 

$privateFunction = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue ) 
Write-Debug ('{0}: Found {1} script files in {2}\Private' -F $MyInvocation.MyCommand.Name, $privateFunction.Count, $PSScriptRoot)

# Public functions will be exported with Prefix prepended to the Noun of the function name

$publicFunction = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue ) 
Write-Debug ('{0}: Found {1} script files in {2}\Public' -F $MyInvocation.MyCommand.Name, $publicFunction.Count, $PSScriptRoot)

# Static functions will be exported with Prefix prepended to the Noun of the function name

$staticFunction = @( Get-ChildItem -Path $PSScriptRoot\Static\*.ps1 -ErrorAction SilentlyContinue ) 
Write-Debug ('{0}: Found {1} script files in {2}\Static' -F $MyInvocation.MyCommand.Name, $staticFunction.Count, $PSScriptRoot)

# Static functions will be exported with Prefix prepended to the Noun of the function name

$dynamicFunction = @( Get-ChildItem -Path $PSScriptRoot\Dynamic\*.ps1 -ErrorAction SilentlyContinue ) 
Write-Debug ('{0}: Found {1} script files in {2}\Dynamic' -F $MyInvocation.MyCommand.Name, $dynamicFunction.Count, $PSScriptRoot)


Write-Verbose ('{0}: Importing {1} Private and {2} Public functions.' -F $MyInvocation.MyCommand.Name, $privateFunction.Count, $publicFunction.Count)

# Loop through all supporting script files and source them
foreach ($import in @($privateFunction + $publicFunction)) {
    Write-Debug ('{0}: Importing {1}' -F $MyInvocation.MyCommand.Name, $import)
    try {
        . $import.fullname
    }
    catch {
        throw "Could not import function $($import.fullname): $_"
    }
}

Write-Verbose ('{0}: Importing {1} Static and {2} Dynamic functions.' -F $MyInvocation.MyCommand.Name, $staticFunction.Count, $dynamicFunction.Count)

# Loop through all script files and source them
foreach ($import in @($staticFunction + $dynamicFunction)) {
    Write-Debug ('{0}: Importing {1}' -F $MyInvocation.MyCommand.Name, $import)

    try {
        . $import.fullname
    }
    catch {
        throw "Could not import function $($import.fullname): $_"
    }
}

# Explicitly export public functions
Write-Verbose ('{0}: Exporting {1} Public functions.' -F $MyInvocation.MyCommand.Name, $publicFunction.Count) 
Export-ModuleMember -Function $publicFunction.Basename

# Set to $true for explicit export of private functions. For debugging purposes only
if ($true){
    # Explicitly export private functions
    Write-Verbose ('{0}: Exporting {1} Private functions.' -F $MyInvocation.MyCommand.Name, $privateFunction.Count) 
    Export-ModuleMember -Function $privateFunction.Basename
}

# Explicitly export static functions
Write-Verbose ('{0}: Exporting {1} Static functions.' -F $MyInvocation.MyCommand.Name, $staticFunction.Count)
Export-ModuleMember -Function $staticFunction.Basename

# Explicitly export dynamic functions
Write-Verbose ('{0}: Exporting {1} Dynamic functions.' -F $MyInvocation.MyCommand.Name, $dynamicFunction.Count)
Export-ModuleMember -Function $dynamicFunction.Basename

# Backwards compatibility since we are now trying to use consistent naming
Set-Alias -Scope Global -Name 'Connect-AutotaskWebAPI' -Value 'Connect-AtwsWebAPI'

# If they tried to pass any variables
if ($Credential) {
    Write-Verbose ('{0}: Parameters detected. Connecting to Autotask API' -F $MyInvocation.MyCommand.Name)

    Try { 
        if ($Credential -is [pscredential]) {
            ## Legacy
            #  The user passed credentials directly
            $Parameters = @{
                Credential               = $Credential
                SecureTrackingIdentifier = ConvertTo-SecureString $ApiTrackingIdentifier -AsPlainText -Force
                DebugPref                = $DebugPreference
                VerbosePref              = $VerbosePreference
            }
            $Configuration = New-AtwsModuleConfiguration @Parameters
        }
        elseif (Test-AtwsModuleConfiguration -Configuration $Credential) {
            ## First parameter was a valid configuration object
            $Configuration = $Credential

            # Switch to configured debug and verbose preferences
            $VerbosePreference = $Configuration.VerbosePref
            $DebugPreference = $Configuration.DebugPref
        }
        else {
            throw (New-Object System.Management.Automation.ParameterBindingException)
        }

        ## Connect to the API
        #  or die trying
        . Connect-AtwsWebServices -Configuration $Configuration -Erroraction Stop
    }
    catch {
        $message = "{0}`n`nStacktrace:`n{1}" -f $_, $_.ScriptStackTrace
        throw (New-Object System.Configuration.Provider.ProviderException $message)
    
        return
    }
    
    # From now on we should have module variable atws available
}
else {
    Write-Verbose 'No Credentials were passed with -ArgumentList. Loading module without any connection to Autotask Web Services. Use Connect-AtwsWebAPI to connect.'
}

# Restore Previous preference
if ($oldVerbosePreference -ne $VerbosePreference) {
    Write-Debug ('{0}: Restoring old Verbose preference' -F $MyInvocation.MyCommand.Name)
    $VerbosePreference = $oldVerbosePreference
}
if ($oldDebugPreference -ne $DebugPreference) {
    Write-Debug ('{0}: Restoring old Debug preference' -F $MyInvocation.MyCommand.Name)
    $DebugPreference = $oldDebugPreference
}