/*
  Azure conversion of the original AWS microservice module.

  High-level resource mapping and important differences:
  - AWS Auto Scaling Group (ASG) -> Azure Virtual Machine Scale Set (`azurerm_linux_virtual_machine_scale_set`).
    Note: ASG offers simple desired/min/max semantics built into the resource. In Azure, VMSS defines a capacity
    (number of instances). To replicate ASG autoscaling behaviour you must attach an `azurerm_monitor_autoscale_setting`.
    This module sets the VMSS `capacity` to `var.min_size` and leaves autoscale as an exercise for the caller.

  - AWS ALB (Application Load Balancer) -> Azure Application Gateway (`azurerm_application_gateway`) for L7
    behaviour, or Azure Load Balancer (`azurerm_lb`) for L4 behaviour. The original AWS module used an ALB which is
    Layer 7 capable (path routing, listeners, host-based rules). For simplicity and clarity this module creates an
    `azurerm_lb` (L4). If you need L7 features (e.g., path-based routing, HTTP rewrite) convert this to use
    `azurerm_application_gateway` instead.

  - AWS Security Groups -> Azure Network Security Groups (`azurerm_network_security_group`) applied to the subnet or
    NICs. There are semantic differences (stateful vs. stateless behaviour and source referencing) and the rules
    must be adapted accordingly.

  - AWS Launch Configuration / AMI -> Azure VM image reference (`source_image_reference`) in VMSS.

  - AWS user-data -> Azure VMSS `custom_data` (must be base64-encoded). This module uses `base64encode(var.user_data_script)`.

  Caveats and mismatches (also inline below near resources):
  - VMSS capacity vs. ASG min/max/desired: autoscaling requires `azurerm_monitor_autoscale_setting` which is
    intentionally out-of-scope here.
  - ALB L7 features won't be available with `azurerm_lb`. Use `azurerm_application_gateway` if you need L7.
  - Azure LB health probes originate from platform-managed IPs; security rules must allow probe traffic.
  - SSH key handling: AWS uses a Key Pair `key_name` that refers to a key stored in AWS. Azure requires the public
    key material. This module expects `var.key_name` to contain the SSH public key text if you want SSH access.
*/

// -------------------------
// NETWORK: vnet, subnet, nsg
// -------------------------

data "azurerm_resource_group" "rg" {
  name     = "rg-student-${var.student_alias}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.student_alias}-${var.name}-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.student_alias}-${var.name}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.student_alias}-${var.name}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.server_http_port)
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

// -------------------------
// LOAD BALANCER (L4) and public IP
// Note: If you need ALB L7 functionality, replace with azurerm_application_gateway
// -------------------------

resource "azurerm_public_ip" "lb_pip" {
  name                = "${var.student_alias}-${var.name}-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "${var.student_alias}-${var.name}-lb"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backendpool" {
  name                = "${var.student_alias}-${var.name}-bepool"
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "http_probe" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  request_path        = "/"
  port                = var.server_http_port
}

resource "azurerm_lb_rule" "http_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = var.alb_http_port
  backend_port                   = var.server_http_port
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.http_probe.id
}

// -------------------------
// VIRTUAL MACHINE SCALE SET
// - Uses `custom_data` to run the user-data script on boot (base64 encoded)
// - Capacity is set to var.min_size; to implement autoscaling configure
//   `azurerm_monitor_autoscale_setting` (not included here).
// -------------------------

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.student_alias}-${var.name}-vmss"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard_B1s"
  instances           = var.min_size

  admin_username = "azureuser"

  # Azure expects the SSH public key text; AWS used a key *name* that refers to a keypair stored in AWS.
  # If you want SSH access, pass the SSH public key text in `var.key_name` (see variables for explanation).
  admin_password = random_password.admin_password.result
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  network_interface {
    name    = "primary"
    primary = true

    ip_configuration {
      name                                   = "internal"
      subnet_id                              = azurerm_subnet.subnet.id
      primary                                = true
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name_prefix = "${var.student_alias}-${var.name}"

  custom_data = base64encode(var.user_data_script)
}

resource "random_password" "admin_password" {
    length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}