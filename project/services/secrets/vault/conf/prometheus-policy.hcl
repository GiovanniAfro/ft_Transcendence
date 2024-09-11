path "secret/prometheus" {
  capabilities = ["read"]
}

path "pki_int/issue/prometheus" {
  capabilities = ["create", "update"]
}
