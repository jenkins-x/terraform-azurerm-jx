autoUpdate:
  enabled: false
  schedule: ""
terraform: true
cluster:
  clusterName: "${cluster_name}"
  devEnvApprovers: %{ if length(dev_env_approvers) == 0 }[]%{ endif }
%{ for name in dev_env_approvers }  - ${name}
%{ endfor }
  environmentGitOwner: "${git_owner_requirement_repos}"
  provider: aks
  registry: "${registry_name}"
gitops: true
environments:
  - key: dev
  - key: staging
  - key: production
ingress:
  domain: "${domain}"
  ignoreLoadBalancer: ${ignore_load_balancer}
  externalDNS: ${enable_external_dns}
  tls:
    email: "${tls_email}"
    enabled: ${enable_tls}
    production: ${use_production_letsencrypt}
kaniko: true
secretStorage: vault
vault:
%{ if external_vault }
  url: ${vault_url}
%{ else }
  azure:
    tenantId: "${vault_tenant_id}"
    vaultName: "${vault_keyvault_name}"
    keyName: "${vault_key_name}"
    storageAccountName: "${vault_storage_account_name}"
    containerName: "${vault_storage_container_name}"
%{ endif }
storage:
  backup:
    enabled: ${enable_backup}
%{ if enable_backup }   
    url: ${backup_container_url}
%{ endif }
  logs:
    enabled: false
  reports:
    enabled: false
  repository:
    enabled: false
%{ if enable_backup }
velero:
  namespace: ${velero_namespace}
  schedule: "${velero_schedule}"
  serviceAccount: ${velero_storage_account}
  ttl: "${velero_ttl}"
  bucketName: "${velero_bucket_name}"
  resourceGroup: "${velero_storage_account_resource_group}"
%{ endif }
versionStream:
  ref: master
  url: https://github.com/jenkins-x/jenkins-x-versions.git
webhook: lighthouse
