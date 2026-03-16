locals {
  common_tags = {
    Assignment     = "CCGC 5502 Automation Assignment"
    Name           = "firstname.lastname"
    ExpirationDate = "2026-12-31"
    Environment    = "Learning"
  }
}

module "rgroup" {
  source   = "./modules/rgroup-0216"
  rg_name  = "0216-RG"
  location = "eastus2"

  tags = {
    Assignment     = "CCGC 5502 Automation Assignment"
    Name           = "firstname.lastname"
    ExpirationDate = "2026-12-31"
    Environment    = "Learning"
  }
}

module "network" {
  source                  = "./modules/network-0216"
  resource_group_name     = module.rgroup.resource_group_name
  location                = "eastus2"
  vnet_name               = "0216-VNET"
  vnet_address_space      = ["10.0.0.0/16"]
  subnet_name             = "0216-SUBNET"
  subnet_address_prefixes = ["10.0.1.0/24"]

  tags = {
    Assignment     = "CCGC 5502 Automation Assignment"
    Name           = "firstname.lastname"
    ExpirationDate = "2026-12-31"
    Environment    = "Learning"
  }
}

module "common" {
  source                       = "./modules/common-0216"
  resource_group_name          = module.rgroup.resource_group_name
  location                     = "eastus2"
  log_analytics_workspace_name = "0216-law"
  recovery_services_vault_name = "rsv-0216"
  storage_account_name         = "st0216commonacct"

  tags = {
    Assignment     = "CCGC 5502 Automation Assignment"
    Name           = "firstname.lastname"
    ExpirationDate = "2026-12-31"
    Environment    = "Learning"
  }
}

module "vmlinux" {
  source                       = "./modules/vmlinux-0216"
  resource_group_name          = module.rgroup.resource_group_name
  location                     = "eastus2"
  subnet_id                    = module.network.subnet_id
  availability_set_name        = "0216-linux-avs"
  vm_base_name                 = "0216-linux"
  vm_names                     = ["0216-linux1", "0216-linux2", "0216-linux3"]
  boot_diagnostics_storage_uri = module.common.storage_account_primary_blob_endpoint
  vm_size                      = "Standard_D2s_v3"
  public_key_path              = "~/.ssh/id_rsa.pub"

  tags = {
    Assignment     = "CCGC 5502 Automation Assignment"
    Name           = "firstname.lastname"
    ExpirationDate = "2026-12-31"
    Environment    = "Learning"
  }
}

module "vmwindows" {
  source                       = "./modules/vmwindows-0216"
  resource_group_name          = module.rgroup.resource_group_name
  location                     = "eastus2"
  subnet_id                    = module.network.subnet_id
  availability_set_name        = "0216-windows-avs"
  vm_name                      = "0216-windows"
  vm_count                     = 1
  boot_diagnostics_storage_uri = module.common.storage_account_primary_blob_endpoint
  vm_size                      = "Standard_D2s_v3"
  admin_password               = "Password1234!"

  tags = {
    Assignment     = "CCGC 5502 Automation Assignment"
    Name           = "firstname.lastname"
    ExpirationDate = "2026-12-31"
    Environment    = "Learning"
  }
}

module "datadisk" {
  source              = "./modules/datadisk-0216"
  resource_group_name = module.rgroup.resource_group_name
  location            = "eastus2"
  linux_vm_ids        = module.vmlinux.linux_vm_ids
  windows_vm_ids      = module.vmwindows.windows_vm_ids

  tags = {
    Assignment     = "CCGC 5502 Automation Assignment"
    Name           = "firstname.lastname"
    ExpirationDate = "2026-12-31"
    Environment    = "Learning"
  }
}

module "loadbalancer" {
  source              = "./modules/loadbalancer-0216"
  resource_group_name = module.rgroup.resource_group_name
  location            = "eastus2"
  lb_name             = "0216-lb"
  public_ip_name      = "0216-lb-pip"
  backend_pool_name   = "0216-lb-backend-pool"
  probe_name          = "0216-lb-probe"
  rule_name           = "0216-lb-rule"
  linux_nic_ids       = module.vmlinux.linux_nic_ids
  ip_config_names     = module.vmlinux.linux_ip_config_names

  tags = {
    Assignment     = "CCGC 5502 Automation Assignment"
    Name           = "firstname.lastname"
    ExpirationDate = "2026-12-31"
    Environment    = "Learning"
  }
}

module "database" {
  source                = "./modules/database-0216"
  resource_group_name   = module.rgroup.resource_group_name
  location              = "eastus2"
  postgresql_server_name = "0216-postgresql"
  db_admin_username     = "dbadmin0216"
  db_admin_password     = "P@ssw0rd0216!"
  db_sku_name           = "B_Standard_B1ms"
  db_storage_mb         = 32768
  db_version            = "13"
  tags                  = local.common_tags
}
