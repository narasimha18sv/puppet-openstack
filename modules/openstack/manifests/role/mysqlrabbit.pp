class openstack::role::mysqlrabbit inherits ::openstack::role {
  class { '::openstack::profile::memcache': }~>
  class { '::openstack::profile::mysql': }~>
  class { '::openstack::profile::rabbitmq': }
}
