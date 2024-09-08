api_addr      = "https://10.0.0.1:8200"

ui = true

#mlock = true
disable_mlock = true

backend "file" {
  path = "/bitnami/vault/"
}

listener "tcp" {
  address            = "10.0.0.1:8200"
  tls_cert_file      = "/bitnami/vault/tls/vault.crt"
  tls_key_file       = "/bitnami/vault/tls/vault.key"
  tls_client_ca_file = "/bitnami/vault/tls/intermediate.cert.pem"
}
