class cinder::volume::local (
  $disk_name,
  $volume_driver     = 'cinder.volume.drivers.lvm.LVMISCSIDriver',
  $volume_group      = 'cinder-volumes',
  $iscsi_helper      = $::cinder::params::iscsi_helper,
) {

  include cinder::params
  package { 'lvm2':
    ensure  => present,
  }~>
  exec { 'lvm physical volume':
    command   => "pvcreate /dev/${disk_name}",
    path      => '/sbin',
    require   => Package['lvm2'],
  }
  exec { 'lvm volume group':
    command   => "vgcreate ${volume_group} /dev/${disk_name}",
    path      => '/sbin',
    require   => Exec['lvm physical volume'],
  }~>
  service{'tgt':
    ensure  => running,
    enable  => 'true',
    subscribe => Exec['lvm volume group']
  } 
}
