terraform {
  required_providers {
    azure = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "2.54.0"
    }
  }
}

provider "azure" {
  subscription_id = var.subscriptionID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resourceGroupName
  location = var.location
}

resource "azurerm_network_security_group" "Frontend" {
  name                = var.nsgNames[0]
  location            = var.location
  resource_group_name = var.resourceGroupName

  security_rule {
    name                       = "https_rule"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh_rule"
    priority                   = 115
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.privConn
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.resource_group]
}

resource "azurerm_network_security_group" "Backend" {
  name                = var.nsgNames[1]
  location            = var.location
  resource_group_name = var.resourceGroupName

  security_rule {
    name                       = "ssh_rule"
    priority                   = 115
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.privConn
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.resource_group]
}

resource "azurerm_network_security_group" "DB" {
  name                = var.nsgNames[2]
  location            = var.location
  resource_group_name = var.resourceGroupName

  security_rule {
    name                       = "ssh_rule"
    priority                   = 115
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.SubnetvNet1FrontendRange
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.resource_group]
}

resource "azurerm_virtual_network" "vNet1" {
  name                = var.vNet1Name
  resource_group_name = var.resourceGroupName
  address_space       = var.vNet1addressspace
  location            = var.location
  depends_on          = [azurerm_network_security_group.Frontend, azurerm_network_security_group.Backend]
}

resource "azurerm_subnet" "FrontendSubnet" {
  name                 = var.SubnetvNet1FrontendName
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.vNet1.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on           = [azurerm_network_security_group.DB]
}

resource "azurerm_subnet_network_security_group_association" "frontassoc" {
  subnet_id                 = azurerm_subnet.FrontendSubnet.id
  network_security_group_id = azurerm_network_security_group.Frontend.id
  depends_on                = [azurerm_subnet.FrontendSubnet, azurerm_network_security_group.Frontend]
}

resource "azurerm_subnet" "BackendSubnet" {
  name                 = var.SubnetvNet1BackendName
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.vNet1.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_network_security_group.Backend]
}

resource "azurerm_subnet_network_security_group_association" "backendassoc" {
  subnet_id                 = azurerm_subnet.BackendSubnet.id
  network_security_group_id = azurerm_network_security_group.Backend.id
  depends_on                = [azurerm_subnet.BackendSubnet, azurerm_network_security_group.Backend]
}

resource "azurerm_virtual_network" "vNet2" {
  name                = var.vNet2Name
  resource_group_name = var.resourceGroupName
  address_space       = var.vNet2addressspace
  location            = var.location
  depends_on          = [azurerm_resource_group.resource_group]
}

resource "azurerm_subnet" "DBSubnet" {
  name                 = var.SubnetvNet2dbName
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.vNet2.name
  address_prefixes     = ["192.168.0.0/24"] # var.SubnetvNet2dbRange
  depends_on           = [azurerm_network_security_group.DB]
}

resource "azurerm_subnet_network_security_group_association" "dbsubnet" {
  subnet_id                 = azurerm_subnet.DBSubnet.id
  network_security_group_id = azurerm_network_security_group.DB.id
  depends_on                = [azurerm_subnet.DBSubnet, azurerm_network_security_group.DB]
}

resource "azurerm_virtual_network_peering" "peering1to2" {
  name                      = var.netPeering[0]
  resource_group_name       = var.resourceGroupName
  virtual_network_name      = var.vNet1Name
  remote_virtual_network_id = azurerm_virtual_network.vNet2.id

  depends_on = [azurerm_virtual_network.vNet2, azurerm_virtual_network.vNet1]
}

resource "azurerm_virtual_network_peering" "peering2to1" {
  name                      = var.netPeering[1]
  resource_group_name       = var.resourceGroupName
  virtual_network_name      = var.vNet2Name
  remote_virtual_network_id = azurerm_virtual_network.vNet1.id

  depends_on = [azurerm_virtual_network.vNet2, azurerm_virtual_network.vNet1]
}

resource "azurerm_public_ip" "publicIp" {
  name                = var.publicIpName
  resource_group_name = var.resourceGroupName
  location            = var.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  depends_on          = [azurerm_resource_group.resource_group]
}

resource "azurerm_network_interface" "networkInterfaceFrontend" {
  name                = var.networkInterfaceFrontend
  location            = var.location
  resource_group_name = var.resourceGroupName

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.FrontendSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIp.id
  }

  depends_on = [azurerm_public_ip.publicIp, azurerm_virtual_network_peering.peering2to1, azurerm_virtual_network_peering.peering1to2]
}

resource "azurerm_network_interface_security_group_association" "nsg-ni_assoc" {
  network_interface_id      = azurerm_network_interface.networkInterfaceFrontend.id
  network_security_group_id = azurerm_network_security_group.Frontend.id
  depends_on                = [azurerm_network_interface.networkInterfaceFrontend, azurerm_network_security_group.Frontend]
}

resource "azurerm_virtual_machine" "vm1" {
  name                  = var.vm1name
  location              = var.location
  resource_group_name   = var.resourceGroupName
  network_interface_ids = [azurerm_network_interface.networkInterfaceFrontend.id]
  vm_size               = var.vm1size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.vm1hostname
    admin_username = var.vm1user
    admin_password = var.vm1password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  depends_on = [azurerm_network_interface.networkInterfaceFrontend]
}
#vm2
resource "azurerm_network_interface" "networkInterfaceDB" {
  name                = var.networkInterfaceDatabase
  location            = var.location
  resource_group_name = var.resourceGroupName

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.DBSubnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [azurerm_virtual_network_peering.peering2to1, azurerm_virtual_network_peering.peering1to2]
}

resource "azurerm_network_interface_security_group_association" "nsg-ni_assoc2" {
  network_interface_id      = azurerm_network_interface.networkInterfaceDB.id
  network_security_group_id = azurerm_network_security_group.DB.id
  depends_on                = [azurerm_network_interface.networkInterfaceDB,azurerm_network_security_group.DB]
}

resource "azurerm_virtual_machine" "vm2" {
  name                  = var.vm2name
  location              = var.location
  resource_group_name   = var.resourceGroupName
  network_interface_ids = [azurerm_network_interface.networkInterfaceDB.id]
  vm_size               = var.vm2size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.vm2hostname
    admin_username = var.vm2user
    admin_password = var.vm2password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  depends_on = [azurerm_network_interface.networkInterfaceDB]
}