# Create subnet
resource "azurerm_subnet" "hu19murugtsubnet" {
    name                 = "hu19murugtsubnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = "hu19-tf-vnet"
    address_prefixes       = ["10.1.152.0/21"]

}

# Create public IPs
resource "azurerm_public_ip" "hu19murugtip" {
    name                         = "hu19murugtip"
    location                     = var.location
    resource_group_name          = var.resource_group_name
    allocation_method            = "Dynamic"

    tags = {
        environment = "practice"
        "createdby" = "murugaraj"

    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "hu19murugtnsg" {
    name                = "hu19murugtnsg"
    location            = var.location
    resource_group_name = var.resource_group_name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "practice"
        "createdby" = "murugraj"
    }
}

# Create network interface
resource "azurerm_network_interface" "hu19murugtnic" {
    name                      = "hu19-murugt-nic"
    location                  = var.location
    resource_group_name       = var.resource_group_name

    ip_configuration {
        name                          = "hu19-murugt-nic-config"
        subnet_id                     = azurerm_subnet.hu19murugtsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.hu19murugtip.id
    }

    tags = {
        environment = "practice"
        "createdby" = "murugaraj"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "hu19murugtnsg" {
    network_interface_id      = azurerm_network_interface.hu19murugtnic.id
    network_security_group_id = azurerm_network_security_group.hu19murugtnsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "hu19murugtstorageaccount" {
    name                        = "hu19murugtstorage"
    resource_group_name         = var.resource_group_name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "practice"
        "createdby" = "murugaraj"
    }
}

# Create  an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_storage_container" "hu19murugtstoragecontainer" {
    name = "hu19-murugt-container"
    storage_account_name = azurerm_storage_account.hu19murugtstorageaccount.name
    container_access_type = "private"
  
}

resource "azurerm_storage_blob" "hu19murugtblob" {
    name = "hu19-murugt-blob"
    storage_account_name = azurerm_storage_account.hu19murugtstorageaccount.name
    storage_container_name = azurerm_storage_container.hu19murugtstoragecontainer.name
    type = "Block"
    source ="cloud-init.txt"
  
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "hu19murugtvm" {
    name                  = "hu19-murgt-vm"
    location              = var.location
    resource_group_name   = var.resource_group_name
    network_interface_ids = [azurerm_network_interface.hu19murugtnic.id]
    size                  = "Standard_DS1_v2"
    custom_data = filebase64("cloud-init.txt")

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "hu19-murugt-vm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.hu19murugtstorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "practice"
        "createdby" = "murugaraj"
    }
}
