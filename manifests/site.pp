include ::openstack::config

node '<swift storage>'{
  include ::openstack::role::swiftcontroller
  include ::openstack::role::swiftstorage
}

node '<keystone node name>' {

  include ::mysql::client
  include ::openstack::role::keystone

}

node '<nova controller node name>'{
  include ::mysql::client
  include ::openstack::role::controller
}

node '<Add this node code to implement HA for any component or node>'{
  $controller01_hostname=hiera('controller01_hostname')
  $controller02_hostname=hiera('controller02_hostname')
  $controller01_mgt_ip=hiera('controller01_mgt_ip')
  $controller02_mgt_ip=hiera('controller02_mgt_ip')
  $controller_cluster_vip=hiera('openstack::controller::address::management')

  sysctl { 'net.ipv4.ip_forward': val => '1' }

  class { keepalived: }

  keepalived::instance { '50':
    interface         => 'eth0',
    virtual_ips       => "${controller_cluster_vip}",
    state             => 'MASTER',
    priority          => '101',
    track_script      => ['haproxy'],
  }

  keepalived::vrrp_script { 'haproxy':
    name_is_process   => true,
  }

  class { 'haproxy': }

  haproxy::listen { 'keystone_public_internal_cluster':
    ipaddress => $controller_cluster_vip,
    ports     => '5000',
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'keystone_public_internal':
    listening_service => 'keystone_public_internal_cluster',
    ports             => '5000',
    server_names      => [$controller01_hostname, $controller02_hostname],
    ipaddresses       => [$controller01_mgt_ip, $controller02_mgt_ip],
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
