output "alb_public_ip" {
  description = "Public IP address assigned to the load balancer"
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "url" {
  description = "HTTP URL to reach the service via the load balancer"
  value       = "http://${azurerm_public_ip.lb_pip.ip_address}:${var.alb_http_port}/"
}