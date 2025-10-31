# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

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

/*
resource "digitalocean_record" "www6" {
  domain = digitalocean_domain.default.name
  type   = "AAAA"
  name   = "www6"
  value  = "2a03:b0c0:1:d0::30b:7001"
}
*/

resource "digitalocean_record" "txt1" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "@"
  value  = "protonmail-verification=61f4835bee8424d6668cf2384ff3da85ba5731a4"
  ttl    = 1800
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
  ttl    = 1800
}

resource "digitalocean_record" "ns2" {
  domain = digitalocean_domain.default.name
  type   = "NS"
  name   = "@"
  value  = "ns2.digitalocean.com."
  ttl    = 1800
}

resource "digitalocean_record" "ns3" {
  domain = digitalocean_domain.default.name
  type   = "NS"
  name   = "@"
  value  = "ns3.digitalocean.com."
  ttl    = 1800
}

resource "digitalocean_record" "dkim1" {
  domain = digitalocean_domain.default.name
  ttl    = 1800
  type   = "CNAME"
  name   = "protonmail._domainkey"
  value  = "protonmail.domainkey.d7wob6rd7ydwemp7nuog2slag3bngwjhtb2ne5re6r4af7h7i56pq.domains.proton.ch."
}

resource "digitalocean_record" "dkim2" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "protonmail2._domainkey"
  value  = "protonmail2.domainkey.d7wob6rd7ydwemp7nuog2slag3bngwjhtb2ne5re6r4af7h7i56pq.domains.proton.ch."
  ttl    = 1800
}

resource "digitalocean_record" "dkim3" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "protonmail3._domainkey"
  value  = "protonmail3.domainkey.d7wob6rd7ydwemp7nuog2slag3bngwjhtb2ne5re6r4af7h7i56pq.domains.proton.ch."
  ttl    = 1800
}

resource "digitalocean_record" "txt4" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "@"
  value  = "google-site-verification=Y2VHPkWr404k4tGcBbXiFCDX8929NzpummmfTm1xpd4"
  ttl    = 1800
}

resource "digitalocean_record" "snowy" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "snowy.lab"
  value  = "10.10.8.11"
}

resource "digitalocean_record" "txt-snowy" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.snowy.lab"
  value  = "RtlYjJD0E5xoX9tczfuDVo9Dr7c0DIa-cJCi1tK9U6g"
  ttl    = 3600
}

resource "digitalocean_record" "time" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "time.lab"
  value  = "10.10.12.13"
  ttl    = 1800
}

resource "digitalocean_record" "txt-time" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.time.lab"
  value  = "aETb3LU6kV89scr6nldxc_8qttd51nAy3NTHJsmqcQU"
  ttl    = 3600
}

resource "digitalocean_record" "head2" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "head2.lab"
  value  = "10.10.12.19"
  ttl    = 1800
}

resource "digitalocean_record" "txt-head2" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.head2.lab"
  value  = "4srO_ixUxViNfwVZTHvstugnP1f0CfRywhhYPdTqqrM"
  ttl    = 3600
}

resource "digitalocean_record" "ldap" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "ldap.lab"
  value  = "10.10.13.1"
  ttl    = 1800
}

resource "digitalocean_record" "txt-ldap" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.ldap.lab"
  value  = "cp9po8ookOwQ6LzTTEEa1l5m12goE56u7rZ4BJRcbGI"
  ttl    = 3600
}

resource "digitalocean_record" "dream-machine" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "dream-machine.lab"
  value  = "10.10.8.1"
  ttl    = 1800
}

resource "digitalocean_record" "txt-dream" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.dream-machine.lab"
  value  = "sfvNfvuSbDHW4FU-oswUHG5tXuDrvTL_OCS4xHhF7Qs"
  ttl    = 3600
}

resource "digitalocean_record" "panorama-a" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "panorama-a.gcp"
  value  = "34.29.159.24"
  ttl    = 1800
}

resource "digitalocean_record" "txt-panorama-a" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.panorama-a.gcp"
  value  = "MwExG8JhCpz6SbIFOfJUENzmheronGXuLDNTWULs4Gk"
  ttl    = 3600
}

resource "digitalocean_record" "airlock" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "airlock.gcp"
  value  = "35.222.82.220"
  ttl    = 1800
}

resource "digitalocean_record" "txt-airlock" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.airlock.gcp"
  value  = "0XDPmTJD8YSl24d49fzINKbcgIhXAxGXeqoVwuYYkpo"
  ttl    = 3600
}

resource "digitalocean_record" "fw-seven" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "fw7.gcp"
  value  = "34.31.56.177"
  ttl    = 1800
}

resource "digitalocean_record" "txt-gcp-fw-seven" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.fw7.gcp"
  value  = "bjPmfxm5zZps4MS6ErGtsTWd28M0wlnGuK0xF0Kl-oc"
  ttl    = 3600
}

resource "digitalocean_record" "fw-six" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "fw6.gcp"
  value  = "34.9.60.250"
  ttl    = 1800
}

resource "digitalocean_record" "txt-gcp-fw-six" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.fw6.gcp"
  value  = "m6PJ7_QIMPycdLsTHTWJkle4p7eeC201dW77b4dspFs"
  ttl    = 3600
}

resource "digitalocean_record" "chonk" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "chonk.lab"
  value  = "10.10.8.60"
}

resource "digitalocean_record" "txt-chonk" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_acme-challenge.chonk.lab"
  value  = "IXrYBujQw0YLrEY2x1e7qX6CxE5zxfSfgc6dWGJ6W9Q"
  ttl    = 3600
}