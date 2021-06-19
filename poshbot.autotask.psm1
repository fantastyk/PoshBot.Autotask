Import-Module AutotaskAPI

function Get-Ticket {
    <#
    .SYNOPSIS
        Retrieves ticket from 
    .EXAMPLE
        !ticket T202000000.0001
    #>
    [PoshBot.BotCommand(CommandName = 'ticket')]
    [cmdletbinding()]
    param(
        [PoshBot.FromConfig('ATIntKey')][Parameter(Mandatory)][string]$ATIntKey,
        [PoshBot.FromConfig('ATUser')][Parameter(Mandatory)][string]$ATUser,
        [PoshBot.FromConfig('ATPassword')][Parameter(Mandatory)][SecureString]$ATPassword,
        [parameter(Mandatory, Position = 0)]
        [string]$ticket
    )

    [pscredential]$cred = New-Object System.Management.Automation.PSCredential ($ATUser, $ATPassword)
    Add-AutotaskAPIAuth -ApiIntegrationcode $ATIntKey -credentials $cred
    if ($ticket -match 'T[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9][0-9][0-9]'){
        $tck = Get-AutotaskAPIResource -Resource Tickets -SimpleSearch "TicketNumber eq $($ticket)"
    }
    else {
        New-PoshBotCardResponse -Type Warning -Title "Invalid Ticket Number"
        return
    }
    if ($tck){
        $hash = [ordered]@{
            Description = $tck.description
            Ticket = "[$ticket](https://ww14.autotask.net/Autotask/AutotaskExtend/ExecuteCommand.aspx?Code=OpenTicketDetail&TicketID=$($tck.id))"
            Company = $(Get-AutotaskAPIResource -Resource Companies -ID $tck.CompanyID).companyName
            #Ticket = $ticket
        }   
        New-PoshbotCardResponse -Type Normal -Fields $hash -Title $tck.title 
    
    }
    else {
        New-PoshBotCardResponse -Type Warning -Title "Can't find this ticket :("
        }
    
}
function Get-Ticket2 {
    <#
    .SYNOPSIS
    Watches for a ticket number in chat and performs a lookup
    .Example
    T202000000.0001
    #>
    [PoshBot.BotCommand(
        Command = $false, 
        TriggerType = 'regex',
        Regex = 'T[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9][0-9][0-9]'
    )]
    [cmdletbinding()]
    param(
        [PoshBot.FromConfig('ATIntKey')][Parameter(Mandatory)][string]$ATIntKey,
        [PoshBot.FromConfig('ATUser')][Parameter(Mandatory)][string]$ATUser,
        [PoshBot.FromConfig('ATPassword')][Parameter(Mandatory)][SecureString]$ATPassword,
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$Arguments
    )
    $ticket = $Arguments[0]
    [pscredential]$cred = New-Object System.Management.Automation.PSCredential ($ATUser, $ATPassword)
    Add-AutotaskAPIAuth -ApiIntegrationcode $ATIntKey -credentials $cred
    
    $tck = Get-AutotaskAPIResource -Resource Tickets -SimpleSearch "TicketNumber eq $($ticket)"

        $hash = [ordered]@{
            Description = $tck.description
            #TicketLink = "https://ww14.autotask.net/Autotask/AutotaskExtend/ExecuteCommand.aspx?Code=OpenTicketDetail&TicketID=$($tck.id)"
            Company = $(Get-AutotaskAPIResource -Resource Companies -ID $tck.CompanyID).companyName
            #Ticket = $ticket
            Ticket = "[$ticket](https://ww14.autotask.net/Autotask/AutotaskExtend/ExecuteCommand.aspx?Code=OpenTicketDetail&TicketID=$($tck.id))"
        }   
    New-PoshbotCardResponse -Type Normal -Fields $hash -Title $tck.title 

}   
Export-ModuleMember -Function 'Get-Ticket','Get-Ticket2'