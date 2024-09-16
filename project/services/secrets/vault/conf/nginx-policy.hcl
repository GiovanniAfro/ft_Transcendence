path "secret/nginx" {
  capabilities = ["read"]
}

path "pki_int/issue/nginx" {
  capabilities = ["create", "update"]
}
