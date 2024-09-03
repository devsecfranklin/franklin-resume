# Create a new domain
resource "digitalocean_domain" "default" {
  name       = "bitsmasher.net"
  ip_address = "178.62.60.55"
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "www"
  value  = "178.62.60.55"
}

resource "digitalocean_record" "www6" {
  domain = digitalocean_domain.default.name
  type   = "AAAA"
  name   = "www6"
  value  = "2a03:b0c0:1:d0::30b:7001"
}

resource "digitalocean_record" "txt1" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "@"
  value  = "protonmail-verification=61f4835bee8424d6668cf2384ff3da85ba5731a4"
}

resource "digitalocean_record" "txt2" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "@"
  value  = "v=spf1 include:_spf.protonmail.ch mx ~all"
}

resource "digitalocean_record" "txt3" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_dmarc"
  value  = "v=DMARC1; p=none; rua=mailto:devescfranklin@duck.com"
}

resource "digitalocean_record" "mx" {
  domain   = digitalocean_domain.default.name
  type     = "MX"
  value    = "mail.protonmail.ch."
  name     = "@"
  priority = "10"
}

resource "digitalocean_record" "ns1" {
  domain = digitalocean_domain.default.name
  type   = "NS"
  name   = "@"
  value  = "ns1.digitalocean.com."
}

resource "digitalocean_record" "ns2" {
  domain = digitalocean_domain.default.name
  type   = "NS"
  name   = "@"
  value  = "ns2.digitalocean.com."
}

resource "digitalocean_record" "ns3" {
  domain = digitalocean_domain.default.name
  type   = "NS"
  name   = "@"
  value  = "ns3.digitalocean.com."
}

resource "digitalocean_record" "gopher" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "gopher"
  value  = "www.bitsmasher.net."
}

resource "digitalocean_record" "dkim1" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "protonmail._domainkey"
  value  = "protonmail.domainkey.d7wob6rd7ydwemp7nuog2slag3bngwjhtb2ne5re6r4af7h7i56pq.domains.proton.ch."
}

resource "digitalocean_record" "dkim2" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "protonmail2._domainkey"
  value  = "protonmail2.domainkey.d7wob6rd7ydwemp7nuog2slag3bngwjhtb2ne5re6r4af7h7i56pq.domains.proton.ch."
}

resource "digitalocean_record" "dkim3" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "protonmail3._domainkey"
  value  = "protonmail3.domainkey.d7wob6rd7ydwemp7nuog2slag3bngwjhtb2ne5re6r4af7h7i56pq.domains.proton.ch."
}

resource "digitalocean_record" "txt4" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "@"
  value  = "google-site-verification=Y2VHPkWr404k4tGcBbXiFCDX8929NzpummmfTm1xpd4"
}

