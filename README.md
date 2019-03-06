# MIM-SPNs-and-Kerberos-Delegations
PowerShell module to get, add and remove Service Principal Names and Kerberos Delegations for MIM service accounts. This module helps preventing mistakes by tying together service_account, SPN and delegation for MIM. The Remove-SPNsAndKerberosDelegation has a safety feature. It lets you see what your'e going to remove. You must type 'Yes' before something happens.

Logics ===>>>

MIM needs to set two Service Principal Names:
1) http/<custom portal name> will be controlled by the 'Mimpool' account that runs the IIS application Pool.
 2) fimservice/<MIM service server name> or fimservice/<MIM service server custom name> will be controlled 'Mimservice'that runs the FIMSERVICE service
 Each custom name must have an A-record and not a Cname record in the DNS.
    
MIM needs to delegate two Kerberos names:
1) 'Mimpool' must be allowed to delegate to fimservice/<MIM service server name> or fimservice/<MIM service server custom name>. 
2) 'Mimservice' may be allowed to delegate to fimservice/<MIM service server name> or fimservice/<MIM service server custom name>. 
So Mimpool is delegating to fimservice/<...> and Mimservice is also delegating to fimservice/<...>. That's a design decision of the application.

Credits to: https://social.technet.microsoft.com/wiki/contents/articles/3385.fim-2010-kerberos-authentication-setup.aspx
Credits to Cookie.Monster (Microsoft MVP) https://gallery.technet.microsoft.com/scriptcenter/Get-SPN-Get-Service-3bd5524a

<####################### PowerShell dump under ###################################>

PS C:\Windows\system32> help Add-SPNsAndKerberosDelegation

NAME
    Add-SPNsAndKerberosDelegation
    
SYNOPSIS
    Add-SPNsAndKerberosDelegation
    
    
SYNTAX
    Add-SPNsAndKerberosDelegation [-domain_dns_name] <Object> 
    [-ServiceAccountName] <Object> [-service_name] <Object> 
    [-delegate_to_service_name] <Object> [<CommonParameters>]
    
    
DESCRIPTION
    MIM needs to set two Service Principal Names:
    1) http/<custom portal name> will be controlled by the 'Mimpool' account 
    that runs the IIS application Pool.
    2) fimservice/<MIM service server name> or fimservice/<MIM service server 
    custom name> will be controlled 'Mimservice'that runs the FIMSERVICE 
    service
    Each custom name must have an A-record and not a Cname record in the DNS.
    
    MIM needs to delegate two Kerberos names:
    1) 'Mimpool' must be allowed to delegate to fimservice/<MIM service server 
    name> or fimservice/<MIM service server custom name>. 
    2) 'Mimservice' may be allowed to delegate to fimservice/<MIM service 
    server name> or fimservice/<MIM service server custom name>. 
    So Mimpool is delegating to fimservice/<...> and Mimservice is also 
    delegating to fimservice/<...>. That's a design decision of the 
    application.
    

RELATED LINKS

REMARKS
    To see the examples, type: "get-help Add-SPNsAndKerberosDelegation 
    -examples".
    For more information, type: "get-help Add-SPNsAndKerberosDelegation 
    -detailed".
    For technical information, type: "get-help Add-SPNsAndKerberosDelegation 
    -full".




PS C:\Windows\system32> help Add-SPNsAndKerberosDelegation -Examples

NAME
    Add-SPNsAndKerberosDelegation
    
SYNOPSIS
    Add-SPNsAndKerberosDelegation
    
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Example of how to use this cmdlet to delegate SPNs in a three tier 
    scenario with only one service server.
    
    
    Add-SPNsAndKerberosDelegation -domain_dns_name test.one 
    -ServiceAccountName mimservice -service_name fimservice/mimservicecli 
    -delegate_to_service_name fimservice/mimservicecli
    Add-SPNsAndKerberosDelegation -domain_dns_name test.one 
    -ServiceAccountName mimpool -service_name http/newmim 
    -delegate_to_service_name fimservice/mimservicecli
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>Another example of how to use this cmdlet in a three tier scenario 
    where a custom dns name is used for the fimservice servers NLB.
    
    
    Add-SPNsAndKerberosDelegation -domain_dns_name test.one 
    -ServiceAccountName mimservice -service_name fimservice/mimservicenlb 
    -delegate_to_service_name fimservice/mimservicenlb
    Add-SPNsAndKerberosDelegation -domain_dns_name test.one 
    -ServiceAccountName mimpool -service_name http/newmim 
    -delegate_to_service_name fimservice/mimservicenlb
    
    
    
    




PS C:\Windows\system32> help Get-SPNsAndKerberosDelegation -Examples

NAME
    Get-SPNsAndKerberosDelegation
    
SYNOPSIS
    Get-SPNsAndKerberosDelegation
    
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Example of how to use this cmdlet to get all kaeberos delegations, 
    and all SPMs for specific service like http or fimservice
    
    
    Get-SPNsAndKerberosDelegation -ServiceAccountName mimpool 
    -spn_service_name http
    Get-SPNsAndKerberosDelegation -ServiceAccountName mimservice 
    -spn_service_name fimservice
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>Another example of how to use this cmdlet
    
    
    n.a.
    
    
    
    




PS C:\Windows\system32> help Remove-SPNsAndKerberosDelegation -Examples

NAME
    Remove-SPNsAndKerberosDelegation
    
SYNOPSIS
    Remove-SPNsAndKerberosDelegation
    
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Example of how to use this cmdlet to remove all http SPNs from the 
    service_account mimpool. You must type 'Yes' to really remove values.
    
    
    Remove-SPNsAndKerberosDelegation -ServiceAccountName mimpool 
    -spn_service_name http
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>Another example of how to use this cmdlet to remove all fimservice 
    SPNs from the service_account MIMService. You must type 'Yes' to really 
    remove values.
    
    
    Remove-SPNsAndKerberosDelegation -ServiceAccountName mimservice 
    -spn_service_name fimservice
    
    
    
    




PS C:\Windows\system32> 
