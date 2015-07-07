class openstack::role::keystone inherits ::openstack::role {
  class { '::openstack::profile::firewall': } ~>
  class { '::openstack::profile::keystone': } ->
  class { '::openstack::profile::auth_file': }
}
