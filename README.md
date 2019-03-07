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

PS C:\Users\SGAdmin> help Remove-SPNsAndKerberosDelegation -Examples

NAME
    Remove-SPNsAndKerberosDelegation
    
SYNOPSIS
    Remove-SPNsAndKerberosDelegation
    
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Example of how to use this cmdlet to remove all http SPNs from the service_account mimpool. You must type 'Yes' to really remove values.
    
    
    Remove-SPNsAndKerberosDelegation -ServiceAccountName mimpool -spn_service_name http
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>Another example of how to use this cmdlet to remove all fimservice SPNs from the service_account MIMService. You must type 'Yes' to really remove values.
    
    
    Remove-SPNsAndKerberosDelegation -ServiceAccountName mimservice -spn_service_name fimservice
    
    
    
    




PS C:\Users\SGAdmin> help Get-SPNsAndKerberosDelegation -Examples

NAME
    Get-SPNsAndKerberosDelegation
    
SYNOPSIS
    Get-SPNsAndKerberosDelegation
    
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Example of how to use this cmdlet to get all kaeberos delegations, and all SPMs for specific service like http or fimservice
    
    
    Get-SPNsAndKerberosDelegation -ServiceAccountName mimpool -spn_service_name http
    Get-SPNsAndKerberosDelegation -ServiceAccountName mimservice -spn_service_name fimservice
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>Another example of how to use this cmdlet
    
    
    n.a.
    
    
    
    




PS C:\Users\SGAdmin> help Add-SPNsAndKerberosDelegation -Detailed

NAME
    Add-SPNsAndKerberosDelegation
    
SYNOPSIS
    Add-SPNsAndKerberosDelegation
    
    
SYNTAX
    Add-SPNsAndKerberosDelegation [-ServiceAccountName] <Object> [-associate_with_service_name] <Object> [-delegate_to_service_name] <Object> [<CommonParameters>]
    
    
DESCRIPTION
    MIM needs to set two Service Principal Names:
    1) http/<custom portal name> will be controlled by the 'Mimpool' account that runs the IIS application Pool.
    2) fimservice/<MIM service server name> or fimservice/<MIM service server custom name> will be controlled 'Mimservice'that runs the FIMSERVICE service
    Each custom name must have an A-record and not a Cname record in the DNS.
    
    MIM needs to delegate two Kerberos names:
    1) 'Mimpool' must be allowed to delegate to fimservice/<MIM service server name> or fimservice/<MIM service server custom name>. 
    2) 'Mimservice' may be allowed to delegate to fimservice/<MIM service server name> or fimservice/<MIM service server custom name>. 
    So Mimpool is delegating to fimservice/<...> and Mimservice is also delegating to fimservice/<...>. That's a design decision of the application.
    

PARAMETERS
    -ServiceAccountName <Object>
        
    -associate_with_service_name <Object>
        
    -delegate_to_service_name <Object>
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    C:\PS>Example of how to use this cmdlet to delegate SPNs in a three tier scenario with only one service server.
    
    Add-SPNsAndKerberosDelegation -ServiceAccountName mimpool -associate_with_service_name http/newmim.test.one -delegate_to_service_name fimservice/mimservicecli.test.one
    Add-SPNsAndKerberosDelegation -ServiceAccountName mimservice -associate_with_service_name fimservice/mimservicecli.test.one -delegate_to_service_name fimservice/mimservicecli.test.one
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    C:\PS>Another example of how to use this cmdlet in a three tier scenario where a custom dns name is used for the fimservice servers NLB.
    
    Add-SPNsAndKerberosDelegation -ServiceAccountName mimpool -associate_with_service_name http/newmim.test.one -delegate_to_service_name fimservice/mimservicenlb.test.one
    Add-SPNsAndKerberosDelegation -ServiceAccountName mimservice -associate_with_service_name fimservice/mimservicenlb.test.one -delegate_to_service_name fimservice/mimservicenlb.test.one
    
    
    
    
REMARKS
    To see the examples, type: "get-help Add-SPNsAndKerberosDelegation -examples".
    For more information, type: "get-help Add-SPNsAndKerberosDelegation -detailed".
    For technical information, type: "get-help Add-SPNsAndKerberosDelegation -full".




PS C:\Users\SGAdmin> Add-SPNsAndKerberosDelegation -ServiceAccountName mimpool -associate_with_service_name http/newmim.test.one -delegate_to_service_name fimservice/mimservicecli.test.one
Associating service_account:mimpool with service:http/newmim.test.one and allowing the same service_account Kerberos delegation to service:fimservice/mimservicecli.test.one.
Try:\> setspn /s http/newmim mimpool
Checking domain DC=test,DC=one

Registering ServicePrincipalNames for CN=MIMpool,OU=MIMAdministration,DC=test,DC=one
	http/newmim
Updated object
Try:\> setspn /s http/newmim.test.one mimpool
Checking domain DC=test,DC=one

Registering ServicePrincipalNames for CN=MIMpool,OU=MIMAdministration,DC=test,DC=one
	http/newmim.test.one
Updated object
SPNs of ServiceAccountName
Registered ServicePrincipalNames for CN=MIMpool,OU=MIMAdministration,DC=test,DC=one:
	http/newmim.test.one
	http/newmim
Try:\> Set-ADUser -Identity mimpool –add @{'msDS-AllowedToDelegateTo'=fimservice/mimservicecli}
Try:\> Set-ADUser -Identity mimpool –add @{'msDS-AllowedToDelegateTo'=fimservice/mimservicecli.test.one}
ServiceAccountName.msDS-AllowedToDelegateTo:
fimservice/mimservicecli.test.one
fimservice/mimservicecli
GARP good

PS C:\Users\SGAdmin> Get-SPNsAndKerberosDelegation -ServiceAccountName mimpool -spn_service_name http 

List mimpool.msDS-AllowedToDelegateTo:
fimservice/mimservicecli.test.one
fimservice/mimservicecli

List the current Service Principal Names of mimpool
http/newmim.test.one
http/newmim

PS C:\Users\SGAdmin> Add-SPNsAndKerberosDelegation -ServiceAccountName mimservice -associate_with_service_name fimservice/mimservicecli.test.one -delegate_to_service_name fimservice/mimservicecli.test.one 
Associating service_account:mimservice with service:fimservice/mimservicecli.test.one and allowing the same service_account Kerberos delegation to service:fimservice/mimservicecli.test.one.
Try:\> setspn /s fimservice/mimservicecli mimservice
Checking domain DC=test,DC=one

Registering ServicePrincipalNames for CN=MIMService,OU=MIMAdministration,DC=test,DC=one
	fimservice/mimservicecli
Updated object
Try:\> setspn /s fimservice/mimservicecli.test.one mimservice
Checking domain DC=test,DC=one

Registering ServicePrincipalNames for CN=MIMService,OU=MIMAdministration,DC=test,DC=one
	fimservice/mimservicecli.test.one
Updated object
SPNs of ServiceAccountName
Registered ServicePrincipalNames for CN=MIMService,OU=MIMAdministration,DC=test,DC=one:
	fimservice/mimservicecli.test.one
	fimservice/mimservicecli
Try:\> Set-ADUser -Identity mimservice –add @{'msDS-AllowedToDelegateTo'=fimservice/mimservicecli}
Try:\> Set-ADUser -Identity mimservice –add @{'msDS-AllowedToDelegateTo'=fimservice/mimservicecli.test.one}
ServiceAccountName.msDS-AllowedToDelegateTo:
fimservice/mimservicecli.test.one
fimservice/mimservicecli
GARP good

PS C:\Users\SGAdmin> Get-SPNsAndKerberosDelegation -ServiceAccountName mimservice -spn_service_name fimservice

List mimservice.msDS-AllowedToDelegateTo:
fimservice/mimservicecli.test.one
fimservice/mimservicecli

List the current Service Principal Names of mimservice
fimservice/mimservicecli.test.one
fimservice/mimservicecli

PS C:\Users\SGAdmin> 
