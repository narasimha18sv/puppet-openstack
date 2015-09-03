# Profile to install the horizon web service
class openstack::profile::horizon {
  class { '::horizon':
    fqdn            => [ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ],
    secret_key      => $::openstack::config::horizon_secret_key,
    cache_server_ip => $::openstack::config::controller_address_management,

  }

  openstack::resources::firewall { 'Apache (Horizon)': port => '80' }
  openstack::resources::firewall { 'Apache SSL (Horizon)': port => '443' }

  if $::selinux and str2bool($::selinux) != false {
    selboolean{'httpd_can_network_connect':
      value      => on,
      persistent => true,
    }
  }

}
