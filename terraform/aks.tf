resource "azurerm_kubernetes_cluster" "cluster" {
#  name                = "${var.resource_group_name}Cluster"
  name                = "MyApp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
#  dns_prefix          = "${var.resource_group_name}Cluster-dns"
  dns_prefix          = "MyApp-dns"

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    network_plugin_mode = "overlay"
  }

  node_provisioning_profile {
    # Karpenter
    default_node_pools = "Auto"
    mode               = "Auto"
  }

  workload_autoscaler_profile {
    keda_enabled = true
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
}