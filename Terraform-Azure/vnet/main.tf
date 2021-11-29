module "vnet"{
    source = "/Users/murugt/documents/TERRAFORM-AZURE/vnet/v_config"
    resource_group_name = "AZRG-USE2-CON-NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    virtual_network_name="hu19-tf-vnet"
    location = "EAST US"
    virtual_subnet_name = "hu19-murugt-subnet"
}