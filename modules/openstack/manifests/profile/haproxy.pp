class openstack::profile::haproxy(
   $hosts_vip  => undef,
   $cluster_hosts => undef,
   $cluster_hosts_ip => undef,
){
  $keystone_public_port=5000
  $keystone_admin_port=35357
  $mysql_port=3306
  $glance_api_port=9292
  $glance_registry_port=9191
  $cinder_port=8776
  $nova_port=8774
  $novnc_port=6080
  $neutron_port=9696
  $rabbitmq_port=5672
  $memcache_port=11211
  $horizon_port=80

  sysctl { 'net.ipv4.ip_nonlocal_bind': val => '1' }~>
  sysctl { 'net.ipv4.ip_forward': val => '1' }~>

  exec {'sysctl':
    command => "/sbin/sysctl -p",
    logoutput => true,
  }
  $priority = 100
  if $hostname == $hostname01 {
        $priority     = 101
  }

  class { 'keepalived': }

  keepalived::instance { "50" :
    interface         => "eth0",
    virtual_ips       => "${hosts_vip}",
    state             => "MASTER",
    priority          => "${priority}",
    track_script      => ['haproxy'],
  }

  keepalived::vrrp_script { 'haproxy':
    name_is_process   => true,
  }

  class { 'haproxy': }
  haproxy::listen { 'mysql_cluster':
    ipaddress => $hosts_vip,
    ports     => $mysql_port,
    mode      => 'tcp',		
    options   => {
      'option'  => [ 'httpchk'],
      'balance' => 'roundrobin'
    }
  }
  haproxy::balancermember { 'mysql_cluster_hosts':
    listening_service => 'mysql_cluster',
    ports             => $mysql_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check port 9200 inter 2000 rise 2 fall 5',
  }
  #Rabbitmq HA
  haproxy::listen { 'rabbitmq cluster':
    ipaddress => $hosts_vip,
    ports     => $rabbit_port,
    mode      => 'tcp',
    options   => {
      'option'  => [ 'httpchk'],
      'balance' => 'roundrobin'
    }
  }~>
  haproxy::balancermember { 'rabbit_cluster_hosts':
    listening_service => 'rabbitmq cluster',
    ports             => $rabbit_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check  inter 2000 rise 2 fall 5',
  }

  haproxy::listen { 'horizon_cluster':
    ipaddress => $hosts_vip,
    ports     => $horizon_port,
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'horizon_cluster_hosts':
    listening_service => 'horizon_cluster',
    ports             => $horizon_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check inter 2000 rise 2 fall 5',
  }
  haproxy::listen { 'keystone_admin_cluster':
    ipaddress => $hosts_vip,
    ports     => $keystone_admin_port,
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'keystone_cluster_hosts':
    listening_service => 'keystone_admin_cluster',
    ports             => $keystone_admin_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check inter 2000 rise 2 fall 5',
  }
  haproxy::listen { 'keystone_public_cluster':
    ipaddress => $hosts_vip,
    ports     => $keystone_public_port,
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'keystone_cluster_hosts_internal':
    listening_service => 'keystone_public_cluster',
    ports             => $keystone_public_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check inter 2000 rise 2 fall 5',
  }
  haproxy::listen { 'memcache_cluster':
    ipaddress => $hosts_vip,
    ports     => $memcache_port,
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'memcache_cluster_hosts':
    listening_service => 'memcache_cluster',
    ports             => $memcache_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check inter 2000 rise 2 fall 5',
  }~>
  haproxy::listen { 'nova_cluster':
    ipaddress => $hosts_vip,
    ports     => $nova_port,
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'nova_cluster_hosts':
    listening_service => 'nova_cluster',
    ports             => $nova_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check inter 2000 rise 2 fall 5',
  }
  haproxy::listen { 'novnc_cluster':
    ipaddress => $hosts_vip,
    ports     => $novnc_port,
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'novnc_cluster_hosts':
    listening_service => 'novnc_cluster',
    ports             => $novnc_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check inter 2000 rise 2 fall 5',
  }
  haproxy::listen { 'neutron_cluster':
    ipaddress => $hosts_vip,
    ports     => $neutron_port,
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'neutron_cluster_hosts':
    listening_service => 'neutron_cluster',
    ports             => $neutron_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check inter 2000 rise 2 fall 5',
  }
  haproxy::listen { 'cinder_cluster':
    ipaddress => $hosts_vip,
    ports     => $cinder_port,
    options   => {
      'option'  => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source'
    }
  }
  haproxy::balancermember { 'cinder_cluster_hosts':
    listening_service => 'cinder_cluster',
    ports             => $cinder_port,
    server_names      => $cluster_hosts,
    ipaddresses       => $cluster_hosts_ip,
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
