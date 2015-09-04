include ::openstack
class { '::openstack::resources::connectors': }
include ::openstack::profile::firewall
$controller_hosts= hiera('controller_hosts')
$controller_hosts_ip= hiera('controller_hosts_ip')
class { '::openstack::profile::haproxy':
   hosts_vip     => $::openstack::config::controller_address_api,
   cluster_hosts  => $controller_hosts,
   cluster_hosts_ip  => $controller_hosts_ip,
}

#include ::openstack::profile::keystone
#include ::openstack::profile::glance::auth
#include ::openstack::profile::glance::api
#include ::openstack::profile::auth_file
#include ::openstack::profile::cinder::api
#include ::openstack::profile::cinder::volume
#include ::openstack::setup::cirros
#include ::openstack::profile::nova::api
#include ::openstack::profile::nova::compute
#include ::openstack::profile::neutron::server
#include ::openstack::profile::horizon
#include ::openstack::profile::neutron::router
#include ::openstack::profile::neutron::agent




