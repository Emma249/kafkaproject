output "resource_group" {
     value = azurerm_resource_group.rg.name 
}

output "vnet_name"      { 
    value = azurerm_virtual_network.vnet.name 
}

output "vault_uri" {
  value = data.azurerm_key_vault.kv.vault_uri
}

# Output VM names
output "vm_names" {
  value = [for vm in azurerm_linux_virtual_machine.vms : vm.name]
}

# Output VM private IPs
output "vm_private_ips" {
  value = [for nic in azurerm_network_interface.nics : nic.private_ip_address]
}
