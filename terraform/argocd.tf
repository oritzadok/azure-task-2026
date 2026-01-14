resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  # To expose Argo CD API server with an external IP
  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
  ]
}


resource "kubernetes_manifest" "argocd_app" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "my-app"
      "namespace" = "argocd"
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = var.git_repo
        "targetRevision" = "HEAD"
        "path"           = "helm"
        "helm"           = {
          "parameters" = [
            {
              "name"  = "image.repository"
              "value" = "${azurerm_container_registry.acr.login_server}/service-bus-consumer"
            },
            {
              "name"  = "image.tag"
              "value" = "latest"
            },
            {
              "name"  = "resources.requests.cpu"
              "value" = "10m"
            },    
            {
              "name"  = "resources.requests.memory"
              "value" = "64Mi"
            }, 
            {
              "name"  = "resources.limits.cpu"
              "value" = "50m"
            },
            {
              "name"  = "resources.limits.memory"
              "value" = "128Mi"
            },
            {
              "name"  = "autoscaling.messageCount"
              "value" = "10"
            },
            {
              "name"  = "serviceAccount.name"
              "value" = "consumer"
            },
            {
              "name"  = "serviceAccount.managedIdentityId"
              "value" = "${azurerm_user_assigned_identity.consumer.client_id}"
            },
            {
              "name"  = "serviceBus.namespace"
              "value" = "${azurerm_servicebus_namespace.sb.name}"
            },
            {
              "name"  = "storageAccount.name"
              "value" = "${azurerm_storage_account.sa.name}"
            },
          ]
        }
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = var.k8s_namespace
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
        "syncOptions" = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    null_resource.build_first_image_tag,
    azurerm_role_assignment.aks_AcrPull,
    null_resource.restart_keda_operator,
    azurerm_role_assignment.keda_roles,
    azurerm_role_assignment.consumer_roles
  ] 
}