# The profile for installing the Cinder API
class openstack::profile::cinder::api {

  $keystone_public_address=$::openstack::config::keystone_public_address
  $keystone_admin_address=$::openstack::config::keystone_admin_address
  openstack::resources::controller { 'cinder': }~>
#  openstack::resources::database { 'cinder': }
  exec{'cinder db sync':
       command => 'cinder-manage db sync',
       path    => '/usr/bin',
  }

  openstack::resources::firewall { 'Cinder API': port => '8776', }

#  class { '::cinder::keystone::auth':
#    password         => $::openstack::config::cinder_password,
#    public_address   => $keystone_public_address,
#    admin_address    => $keystone_admin_address,
#    internal_address => $keystone_admin_address,
#    region           => $::openstack::config::region,
#  }

  include ::openstack::common::cinder

  class { '::cinder::api':
    keystone_password  => $::openstack::config::cinder_password,
    keystone_auth_host => $::openstack::config::keystone_public_address,
    enabled            => true,
  }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
    enabled          => true,
  }
}
