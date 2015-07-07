# The profile to install the Keystone service
class openstack::profile::keystone {

  openstack::resources::controller { 'keystone': }~>
#  openstack::resources::database { 'keystone': }
   exec{'keystone db sync':
     command  => 'keystone-manage db_sync',
     path     => '/usr/bin',
   }

  openstack::resources::firewall { 'Keystone API': port => '5000', }

  include ::openstack::common::keystone
  class { 'keystone::endpoint':
    public_address   => $::openstack::config::keystone_public_address,
    admin_address    => $::openstack::config::keystone_admin_address,
    internal_address => $::openstack::config::keystone_admin_address,
    region           => $::openstack::config::region,
  }~> notify {"keystone endpoint created":}~>
  class  { '::glance::keystone::auth':
    password         => $::openstack::config::glance_password,
#    public_address   => $::openstack::controller::address::api,
#    admin_address    => $::openstack::controller::address::management,
#    internal_address => $::openstack::controller::address::management,
    public_address   => hiera(openstack::controller::address::api),
    admin_address    => hiera(openstack::controller::address::management),
    internal_address => hiera(openstack::controller::address::management),
    region           => $::openstack::config::region,
  }~>
  class { '::cinder::keystone::auth':
    password         => $::openstack::config::cinder_password,
    public_address   => hiera(openstack::controller::address::api),
    admin_address    => hiera(openstack::controller::address::management),
    internal_address => hiera(openstack::controller::address::management),
    region           => $::openstack::config::region,
  }~>
  class { '::nova::keystone::auth':
    password         => $::openstack::config::nova_password,
    public_address   => hiera(openstack::controller::address::api),
    admin_address    => hiera(openstack::controller::address::management),
    internal_address => hiera(openstack::controller::address::management),
    region           => $::openstack::config::region,
    cinder           => true,
  }~>
  class { '::neutron::keystone::auth':
    password         => $::openstack::config::neutron_password,
    public_address   => $::openstack::config::controller_address_api,
    admin_address    => $::openstack::config::controller_address_management,
    internal_address => $::openstack::config::controller_address_management,
    region           => $::openstack::config::region,
  }


  $tenants = $::openstack::config::keystone_tenants
  $users   = $::openstack::config::keystone_users
  create_resources('openstack::resources::tenant', $tenants)
  create_resources('openstack::resources::user', $users)
}
