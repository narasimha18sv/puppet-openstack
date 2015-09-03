# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::glance::auth {
  openstack::resources::controller { 'glance': }
  openstack::resources::database { 'glance': }~> exec{'glance db sync':
       command  => 'glance-manage db_sync',
       path     => '/usr/bin',
  }


  class  { '::glance::keystone::auth':
    password         => $::openstack::config::glance_password,
    public_address   => $::openstack::config::storage_address_api,
    admin_address    => $::openstack::config::storage_address_management,
    internal_address => $::openstack::config::storage_address_management,
    region           => $::openstack::config::region,
  }

  include ::openstack::common::glance
}
