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

resource "azurerm_nat_gateway" "nat_gateway" {
  count = var.is_internal_alb ? 0 : 1
  name                = "${var.student_alias}-${var.name}-natgateway"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet_nat_gateway_association" "nat_gateway_association" {
  count = var.is_internal_alb ? 0 : 1
  subnet_id      = azurerm_subnet.subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway[0].id
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_pip_association" {
  count = var.is_internal_alb ? 0 : 1
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway[0].id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

resource "azurerm_public_ip" "nat_pip" {
  name                = "${var.student_alias}-${var.name}-nat-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
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

  security_rule {
    name                       = "Allow-HTTP-Outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.server_http_port)
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


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

resource "azurerm_network_interface" "nic" {
  name                = "${var.student_alias}-${var.name}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                                   = "internal"
    subnet_id                              = azurerm_subnet.subnet.id
    private_ip_address_allocation          = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.student_alias}-${var.name}-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_B1s"

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_username = "azureuser"
  admin_password = random_password.admin_password.result
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name = "${var.student_alias}-${var.name}"

  custom_data = base64encode(var.user_data_script)
}

resource "random_password" "admin_password" {
    length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}