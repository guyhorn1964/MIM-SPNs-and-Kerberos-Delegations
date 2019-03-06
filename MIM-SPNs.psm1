<#
.Synopsis
   Remove-SPNsAndKerberosDelegation
.DESCRIPTION
   Remove-SPNsAndKerberosDelegation
.EXAMPLE
   Example of how to use this cmdlet to remove all http SPNs from the service_account mimpool. You must type 'Yes' to really remove values.
   Remove-SPNsAndKerberosDelegation -ServiceAccountName mimpool -spn_service_name http
.EXAMPLE
   Another example of how to use this cmdlet to remove all fimservice SPNs from the service_account MIMService. You must type 'Yes' to really remove values.
   Remove-SPNsAndKerberosDelegation -ServiceAccountName mimservice -spn_service_name fimservice
#>
function Remove-SPNsAndKerberosDelegation ([Parameter(Mandatory=$true)]$ServiceAccountName, [Parameter(Mandatory=$true)]$spn_service_name)
{   
    write-host 'Remove all Kerberos delagations?' -ForegroundColor Cyan -NoNewline
    $Go = Read-Host '   Then, type Yes to remove all Kerberos delegations'
    if ($Go -like 'yes'){Set-ADUser -Identity $ServiceAccountName –clear 'msDS-AllowedToDelegateTo'}
    
    # Remove SPNs
    $spns = get-spn -ServiceClass $spn_service_name | Where-Object -FilterScript {($_.samAccountName -like $ServiceAccountName)}
    foreach ($spn in $spns)
    {
        write-host "Remove this Service Principal Name (SPN? )" $spn.spn -ForegroundColor Cyan -NoNewline
        $Go = Read-Host '    Then, Type Yes to remove all Kerberos delegations'
        if ($Go -like 'yes'){setspn /d $spn.SPN $ServiceAccountName}
    }
    setspn /l $ServiceAccountName
}

<#
.Synopsis
   Add-SPNsAndKerberosDelegation
.DESCRIPTION
   MIM needs to set two Service Principal Names:
   1) http/<custom portal name> will be controlled by the 'Mimpool' account that runs the IIS application Pool.
   2) fimservice/<MIM service server name> or fimservice/<MIM service server custom name> will be controlled 'Mimservice'that runs the FIMSERVICE service
   Each custom name must have an A-record and not a Cname record in the DNS.

   MIM needs to delegate two Kerberos names:
   1) 'Mimpool' must be allowed to delegate to fimservice/<MIM service server name> or fimservice/<MIM service server custom name>. 
   2) 'Mimservice' may be allowed to delegate to fimservice/<MIM service server name> or fimservice/<MIM service server custom name>. 
   So Mimpool is delegating to fimservice/<...> and Mimservice is also delegating to fimservice/<...>. That's a design decision of the application.
.EXAMPLE
   Example of how to use this cmdlet to delegate SPNs in a three tier scenario with only one service server. 
   Add-SPNsAndKerberosDelegation -domain_dns_name test.one -ServiceAccountName mimservice -service_name fimservice/mimservicecli -delegate_to_service_name fimservice/mimservicecli
   Add-SPNsAndKerberosDelegation -domain_dns_name test.one -ServiceAccountName mimpool -service_name http/newmim -delegate_to_service_name fimservice/mimservicecli
   
.EXAMPLE
   Another example of how to use this cmdlet in a three tier scenario where a custom dns name is used for the fimservice servers NLB. 
   Add-SPNsAndKerberosDelegation -domain_dns_name test.one -ServiceAccountName mimservice -service_name fimservice/mimservicenlb -delegate_to_service_name fimservice/mimservicenlb
   Add-SPNsAndKerberosDelegation -domain_dns_name test.one -ServiceAccountName mimpool -service_name http/newmim -delegate_to_service_name fimservice/mimservicenlb

#>
function Add-SPNsAndKerberosDelegation 
{

    Param
    (
        [Parameter(Mandatory=$true)]$domain_dns_name,
        [Parameter(Mandatory=$true)]$ServiceAccountName,
        [Parameter(Mandatory=$true)]$service_name,
        [Parameter(Mandatory=$true)]$delegate_to_service_name
    )
    Write-Host "!! Log on as domain admin. Start PowerShell ISE as administrator !!" -ForegroundColor Cyan
    Write-Host "!! Create DNS A-record for $spnfqdn. The IP address is the one of the MIMPortal server !!" -ForegroundColor Cyan
    Write-Host "!! Control the SPN's. Type Yes to go on. Type no or enter to skip the script. !!" -ForegroundColor Cyan
    Write-host "!! Delegating spnfqdn and spnrdn: $spnfqdn,$spnrdn to service account: $Domain\$ServiceAccountName !!" -ForegroundColor Cyan
    $go = Read-Host -Prompt "Type Yes to go on. Type no or enter to skip the script."
    if ($go -eq 'Yes')
    {
        # check and prepare params params
        ## Check $service_name = "http/newmim"
        (Resolve-DnsName -Name $service_name.Split('/')[1]).name # DNS A record fqdn
        ## Check $delegate_to_service_name = "fimservice/mimservicecli"
        (Resolve-DnsName -Name $delegate_to_service_name.Split('/')[1]).name # DNS A record fqdn
        if ($error)
        {
            throw $error
            exit
        }
        
        # set spn's
        setspn /s $service_name $ServiceAccountName
        setspn /s ($service_name + '.' + $domain_dns_name) $ServiceAccountName
        Write-Host 'SPNs of ServiceAccountName' -ForegroundColor Cyan
        setspn /l $ServiceAccountName


        # allow delegation
        Set-ADUser -Identity $ServiceAccountName –add @{'msDS-AllowedToDelegateTo'=$delegate_to_service_name} 
        Set-ADUser -Identity $ServiceAccountName –add @{'msDS-AllowedToDelegateTo'=($delegate_to_service_name + '.' + $domain_dns_name)}
        Write-Host "ServiceAccountName.msDS-AllowedToDelegateTo:" -ForegroundColor Cyan
        (Get-ADUser -Identity $ServiceAccountName -Properties *).'msDS-AllowedToDelegateTo'
    }
}

<#
.Synopsis
   Get-SPNsAndKerberosDelegation
.DESCRIPTION
   Get-SPNsAndKerberosDelegation
.EXAMPLE
   Example of how to use this cmdlet to get all kaeberos delegations, and all SPMs for specific service like http or fimservice
   Get-SPNsAndKerberosDelegation -ServiceAccountName mimpool -spn_service_name http
   Get-SPNsAndKerberosDelegation -ServiceAccountName mimservice -spn_service_name fimservice

.EXAMPLE
   Another example of how to use this cmdlet
   n.a.

#>
function Get-SPNsAndKerberosDelegation ([Parameter(Mandatory=$true)]$ServiceAccountName,[Parameter(Mandatory=$true)]$spn_service_name)
{
   

    # get delagations
    write-host "`nList $ServiceAccountName`.msDS-AllowedToDelegateTo:" -ForegroundColor Cyan
    (Get-ADUser -Identity $ServiceAccountName -Properties *).'msDS-AllowedToDelegateTo'

    # get SPNs
    $spns = get-spn -ServiceClass $spn_service_name | Where-Object -FilterScript {($_.samAccountName -like $ServiceAccountName)}
    Write-Host "`nList the current Service Principal Names of $ServiceAccountName" -ForegroundColor Cyan
    foreach ($spn in $spns)
    {
        $spn.SPN 
    }
    
}


function Get-SPN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        {
    <#
    .SYNOPSIS
        Get Service Principal Names

    .DESCRIPTION
        Get Service Principal Names

        Output includes:
            ComputerName - SPN Host
            Specification - SPN Port (or Instance)
            ServiceClass - SPN Service Class (MSSQLSvc, HTTP, etc.)
            sAMAccountName - sAMAccountName for the AD object with a matching SPN
            SPN - Full SPN string

    .PARAMETER ComputerName
        One or more hostnames to filter on.  Default is *

    .PARAMETER ServiceClass
        Service class to filter on.
        
        Examples:
            HOST
            MSSQLSvc
            TERMSRV
            RestrictedKrbHost
            HTTP

    .PARAMETER Specification
        Filter results to this specific port or instance name

    .PARAMETER SPN
        If specified, filter explicitly and only on this SPN.  Accepts Wildcards.

    .PARAMETER Domain
        If specified, search in this domain. Use a fully qualified domain name, e.g. contoso.org

        If not specified, we search the current user's domain

    .EXAMPLE
        Get-Spn -ServiceType MSSQLSvc
        
        #This command gets all MSSQLSvc SPNs for the current domain
    
    .EXAMPLE
        Get-Spn -ComputerName SQLServer54, SQLServer55
        
        #List SPNs associated with SQLServer54, SQLServer55
    
    .EXAMPLE
        Get-SPN -SPN http*

        #List SPNs maching http*
    
    .EXAMPLE
        Get-SPN -ComputerName SQLServer54 -Domain Contoso.org

        # List SPNs associated with SQLServer54 in contoso.org

    .NOTES 
        Adapted from
            http://www.itadmintools.com/2011/08/list-spns-in-active-directory-using.html
            http://poshcode.org/3234
        Version History 
            v1.0   - Chad Miller - Initial release 
            v1.1   - ramblingcookiemonster - added parameters to specify service type, host, and specification
            v1.1.1 - ramblingcookiemonster - added parameterset for explicit SPN lookup, added ServiceClass to results

    .FUNCTIONALITY
        Active Directory             
#>
    
    [cmdletbinding(DefaultParameterSetName='Parse')]
    param(
        [Parameter( Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    ParameterSetName='Parse' )]
        [string[]]$ComputerName = "*",

        [Parameter(ParameterSetName='Parse')]
        [string]$ServiceClass = "*",

        [Parameter(ParameterSetName='Parse')]
        [string]$Specification = "*",

        [Parameter(ParameterSetName='Explicit')]
        [string]$SPN,

        [string]$Domain
    )
    
    #Set up domain specification, borrowed from PyroTek3
    #https://github.com/PyroTek3/PowerShell-AD-Recon/blob/master/Find-PSServiceAccounts
        if(-not $Domain)
        {
            $ADDomainInfo = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
            $Domain = $ADDomainInfo.Name
        }
        $DomainDN = "DC=" + $Domain -Replace("\.",',DC=')
        $DomainLDAP = "LDAP://$DomainDN"
        Write-Verbose "Search root: $DomainLDAP"

    #Filter based on service type and specification.  For regexes, convert * to .*
        if($PsCmdlet.ParameterSetName -like "Parse")
        {
            $ServiceFilter = If($ServiceClass -eq "*"){".*"} else {$ServiceClass}
            $SpecificationFilter = if($Specification -ne "*"){".$Domain`:$specification"} else{"*"}
        }
        else
        {
            #To use same logic as 'parse' parameterset, set these variables up...
                $ComputerName = @("*")
                $Specification = "*"
        }

    #Set up objects for searching
        $SearchRoot = [ADSI]$DomainLDAP
        $searcher = New-Object System.DirectoryServices.DirectorySearcher
        $searcher.SearchRoot = $SearchRoot
        $searcher.PageSize = 1000

    #Loop through all the computers and search!
    foreach($computer in $ComputerName)
    {
        #Set filter - Parse SPN or use the explicit SPN parameter
        if($PsCmdlet.ParameterSetName -like "Parse")
        {
            $filter = "(servicePrincipalName=$ServiceClass/$computer$SpecificationFilter)"
        }
        else
        {
            $filter = "(servicePrincipalName=$SPN)"
        }
        $searcher.Filter = $filter

        Write-Verbose "Searching for SPNs with filter $filter"
        foreach ($result in $searcher.FindAll()) {

            $account = $result.GetDirectoryEntry()
            foreach ($servicePrincipalName in $account.servicePrincipalName.Value) {
                
                #Regex will capture computername and port/instance
                if($servicePrincipalName -match "^(?<ServiceClass>$ServiceFilter)\/(?<computer>[^\.|^:]+)[^:]*(:{1}(?<port>\w+))?$") {
                    
                    #Build up an object, get properties in the right order, filter on computername
                    New-Object psobject -property @{
                        ComputerName=$matches.computer
                        Specification=$matches.port
                        ServiceClass=$matches.ServiceClass
                        sAMAccountName=$($account.sAMAccountName)
                        SPN=$servicePrincipalName
                    } | 
                        Select-Object ComputerName, Specification, ServiceClass, sAMAccountName, SPN |
                        #To get results that match parameters, filter on comp and spec
                        Where-Object {$_.ComputerName -like $computer -and $_.Specification -like $Specification}
                } 
            }
        }
    }
    } #Get-Spn


#Add-SPNsAndKerberosDelegation -domain_dns_name test.one -ServiceAccountName mimpool -service_name http/newmim -delegate_to_service_name fimservice/mimservicecli 

#Add-SPNsAndKerberosDelegation -domain_dns_name test.one -ServiceAccountName mimpool -service_name http/mim -delegate_to_service_name fimservice/mimwithallroles




