terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
#variable "pvt_keys" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "web" {
  image    = "rockylinux-9-x64"
  name     = "web-1"
  region   = "AMS3"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["you-ssh-key-id"]
}

resource "digitalocean_domain" "domain" {
  name = "you.domain"

}

resource "digitalocean_record" "main" {
  domain = digitalocean_domain.domain.name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.web.ipv4_address

}

resource "digitalocean_record" "www_main" {
  domain = digitalocean_domain.domain.name
  type   = "A"
  name   = "www"
  value  = digitalocean_droplet.web.ipv4_address

}
