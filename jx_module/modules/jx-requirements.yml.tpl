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
  registry: "${registry_name}.azurecr.io"
gitops: true
environments:
  - key: dev
  - key: staging
  - key: production
ingress:
  domain: "${domain}"
  ignoreLoadBalancer: true
  externalDNS: ${enable_external_dns}
  tls:
    email: "${tls_email}"
    enabled: ${enable_tls}
    production: ${use_production_letsencrypt}
kaniko: true
secretStorage: local
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
