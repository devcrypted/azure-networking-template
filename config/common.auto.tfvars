pname       = "contoso-net"
environment = "prod"

default_tags = {
  terraform = "true"
  stack     = "hub-spoke-v2"
  owner     = "platform-team"
}

dns_zones = [
  "privatelink.blob.core.windows.net",
  "privatelink.database.windows.net",
  "corp.contoso.com"
]
