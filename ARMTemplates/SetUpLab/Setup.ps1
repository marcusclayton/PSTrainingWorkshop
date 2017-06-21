#Deploy DTL
#Set VM auto-start policy
#Enable on each VM: #ref: https://social.msdn.microsoft.com/Forums/en-US/abc034ea-22a7-444c-b903-e17133217602/anyway-to-force-out-autostart-policy-on-vms-in-our-dev-test-lab?forum=AzureDevTestLabs
$tags += @{AutoStartOn=$true}
Get-AzureRmResource | ?{$_.name -like "Lab-*" -and $_.ResourceType -eq 'Microsoft.Compute/virtualMachines'} | %{Set-AzureRmResource -ResourceId $_.resourceid -Tag $tags -Confirm:$false -Force -Verbose}