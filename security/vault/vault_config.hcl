ui = true

storage "consul" {
  address = "127.0.0.1:8500"
  http_idle_timeout = "10m"
  path    = "vault"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  http_idle_timeout = "10m"
  storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  http_idle_timeout = "10m"
  tls_disable = 1
}

telemetry {
  statsite_address = "127.0.0.1:8125"
  disable_hostname = true
}
  tls_disable = 1
}

telemetry {
  statsite_address = "127.0.0.1:8125"
  disable_hostname = true
}
