# The puppet module to set up a Nova Compute node
class openstack::profile::nova::compute {
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)
  $backend            = hiera('nova_backend')  

#  class { 'openstack::common::nova':
#    is_compute => true,
#  }
  
  if $backend == 'vmware'
  {
      class {'nova::compute::vmware' :
          host_ip => $::openstack::config::host_ip,
          host_username => $::openstack::config::host_username,
          host_password => $::openstack::config::host_password,
          cluster_name => $::openstack::config::cluster_name,
      }
   }
   elsif $backend == 'kvm'
   {
       class { '::nova::compute::libvirt':
          libvirt_virt_type => $::openstack::config::nova_libvirt_type,
          vncserver_listen  => $management_address,
       }
       class { 'nova::migration::libvirt':
       }

       file { '/etc/libvirt/qemu.conf':
          ensure => present,
          source => 'puppet:///modules/openstack/qemu.conf',
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          notify => Service['libvirt'],
        }
        Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
    }
}
