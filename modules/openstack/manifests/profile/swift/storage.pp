# The profile for installing a single loopback storage node
class openstack::profile::swift::storage (
  $zone = undef,
) {
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)
  $storage_node_address = $::openstack::config::storage_address_management
  $storage_node_drive = hiera(openstack::config::storage_drive)
  $storage_partition_type = hiera(openstack::config::storage_partition_type)
  firewall { '6000 - Swift Object Store':
    proto  => 'tcp',
    state  => ['NEW'],
    action => 'accept',
    port   => '6000',
  }

  firewall { '6001 - Swift Container Store':
    proto  => 'tcp',
    state  => ['NEW'],
    action => 'accept',
    port   => '6001',
  }

  firewall { '6002 - Swift Account Store':
    proto  => 'tcp',
    state  => ['NEW'],
    action => 'accept',
    port   => '6002',
  }

  class { '::swift':
    swift_hash_suffix => $::openstack::config::swift_hash_suffix,
  }

  swift::storage::loopback { '1':
    base_dir     => '/srv/swift-loopback',
    mnt_base_dir => '/srv/node',
    byte_size    => 1024,
    seek         => 10000,
    fstype       => 'ext4',
    require      => Class['swift'],
  }

  class { '::swift::storage::all':
    storage_local_net_ip => $management_address
  }

  @@ring_object_device { "${management_address}:6000/1":
    zone   => $zone,
    weight => 1,
  }

  @@ring_container_device { "${management_address}:6001/1":
    zone   => $zone,
    weight => 1,
  }

  @@ring_account_device { "${management_address}:6002/1":
    zone   => $zone,
    weight => 1,
  }

exec {'create_storage_drive':
                command => ["/sbin/mkfs.${storage_partition_type} -F  /dev/${storage_node_drive}"],
                logoutput => "true",
                unless => '/bin/grep "/dev/${storage_node_drive}" /etc/fstab',
                #require => Class['swift::ringbuilder'],
}


mount { "/srv/node/${storage_node_drive}":
        device  => "/dev/${storage_node_drive}",
        fstype  => "${storage_partition_type}",
        ensure  => "mounted",
        options => "defaults",
        atboot  => "true",
        require => Exec["create_storage_drive"],
}

exec { "Ensure_ownership":
        command => ["/bin/chown -R swift:swift /srv/node"],
        logoutput => "true",
        returns => ['2','0'],
}

file { "/var/cache/swift":
        ensure => 'directory',
        owner => 'swift',
        group => 'swift',

}


exec {'creating_Rings':
                command => ["/usr/bin/swift-ring-builder account.builder add z1-${storage_node_address}:6002/${storage_node_drive} 110"],
                returns => ['2','0'],
                logoutput => "true",
                #require => Class['swift::ringbuilder'],
}

exec {'creating_Rings1':
                command => ["/usr/bin/swift-ring-builder container.builder add z1-${storage_node_address}:6001/${storage_node_drive} 110"],
                returns => ['2','0'],
                logoutput => "true",
                #require => Class['swift::ringbuilder'],
}

exec {'creating_Rings2':
                command => ["/usr/bin/swift-ring-builder object.builder add z1-${storage_node_address}:6000/${storage_node_drive} 110"],
                returns => ['2','0'],
                logoutput => "true",
                #require => Class['swift::ringbuilder'],
}
exec {'Rebalancing':
                command => ["/usr/bin/swift-ring-builder account.builder rebalance"],
                returns => ['2','0'],
#               require => Exec['creating_Rings'],
}

exec {'Rebalancing1':
                command => ["/usr/bin/swift-ring-builder container.builder rebalance"],
                returns => ['2','0'],
 #               require => Exec['creating_Rings1'],
}

exec {'Rebalancing2':
                command => ["/usr/bin/swift-ring-builder object.builder rebalance"],
                returns => ['2','0'],
  #              require => Exec['creating_Rings2'],
}


  swift::ringsync { ['account','container','object']:
    ring_server => $::openstack::config::controller_address_management,
  }
}
