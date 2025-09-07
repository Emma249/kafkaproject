# Create resource group name for the cluster and project
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

#create v-net for the entire setup
resource "azurerm_virtual_network" "vnet" {

  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnets" {
for_each = {
subnet1  = "10.0.1.0/24"
subnet2  = "10.0.2.0/24"
subnet3  = "10.0.3.0/24"
}

name                = each.key
resource_group_name = azurerm_resource_group.rg.name
virtual_network_name = "${var.prefix}-vnet"
address_prefixes = [each.value] # comment out so Terraform will not recreate this
}

resource "azurerm_public_ip" "PIP" {
  name                = "${var.prefix}-PIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "NatGateway" {
  name                = "${var.prefix}-NatGateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.NatGateway.id
  public_ip_address_id = azurerm_public_ip.PIP.id
}

# Associate NAT with each subnet
resource "azurerm_subnet_nat_gateway_association" "subnet_natgateway_assoc" {
    for_each = azurerm_subnet.subnets
    subnet_id      = each.value.id
    nat_gateway_id = azurerm_nat_gateway.NatGateway.id   
}

# Create NICs in each subnet
resource "azurerm_network_interface" "nics" {
  for_each            = azurerm_subnet.subnets
  name                = "${each.key}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = each.value.id
    private_ip_address_allocation = "Dynamic"
  }


}

data "azurerm_key_vault" "kv" {
  name                = "Tfvault123"
  resource_group_name = "sysroom"
}

data "azurerm_key_vault_secret" "vm1" {
  name         = "Kafkavm1"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "vm2" {
  name         = "Kafkavm2"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "vm3" {
  name         = "Kafkavm3"
  key_vault_id = data.azurerm_key_vault.kv.id
}

locals {
  vm_passwords = {
    subnet1 = data.azurerm_key_vault_secret.vm1.value
    subnet2 = data.azurerm_key_vault_secret.vm2.value
    subnet3 = data.azurerm_key_vault_secret.vm3.value
  }
}

# Create VMs in each subnet
resource "azurerm_linux_virtual_machine" "vms" {
  for_each              = azurerm_network_interface.nics
  name                  = "${each.key}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B4ms"
  network_interface_ids = [each.value.id]

  admin_username  = "${each.key}buttercup"
    disable_password_authentication = false
 admin_password                  = local.vm_passwords[each.key]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

#create a bastion host
resource "azurerm_subnet" "bastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.96/27"]
}

resource "azurerm_public_ip" "pip" {
  name                = "bastpip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "basthost" {
  name                = "kafkabastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastionsubnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

