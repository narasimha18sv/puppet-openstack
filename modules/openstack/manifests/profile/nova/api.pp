# The profile to set up the Nova controller (several services)
class openstack::profile::nova::api {
  openstack::resources::controller { 'nova': }~>
#  openstack::resources::database { 'nova': }
 
  exec{'nova db sync':
     command  => 'nova-manage db sync',
     path     => '/usr/bin',
   }

  openstack::resources::firewall { 'Nova API': port => '8774', }
  openstack::resources::firewall { 'Nova Metadata': port => '8775', }
#  openstack::resources::firewall { 'Nova EC2': port => '8773', }
#  openstack::resources::firewall { 'Nova S3': port => '3333', }
  openstack::resources::firewall { 'Nova novnc': port => '6080', }

#  class { '::nova::keystone::auth':
#    password         => $::openstack::config::nova_password,
#    public_address   => $::openstack::config::keystone_public_address,
#    admin_address    => $::openstack::config::keystone_admin_address,
#    internal_address => $::openstack::config::keystone_admin_address,
#    region           => $::openstack::config::region,
#    cinder           => true,
#  }

  include ::openstack::common::nova
}
