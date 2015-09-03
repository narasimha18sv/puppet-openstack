include ::openstack
class { '::openstack::resources::connectors': }
include ::openstack::profile::firewall
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
include ::openstack::profile::neutron::router
include ::openstack::profile::neutron::agent




