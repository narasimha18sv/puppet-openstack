class openstack::common::keystone {
  if $::openstack::profile::base::is_controller {
    $admin_bind_host = '0.0.0.0'
  } else {
    $admin_bind_host = $::openstack::config::controller_address_management
  }
  $connection = $::openstack::resources::connectors::keystone
  notify {" connection variable ${connection} ":}
  class { '::keystone':
    admin_token         => $::openstack::config::keystone_admin_token,
    database_connection => $connection,
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled             => $::openstack::profile::base::is_controller,
    admin_bind_host     => $admin_bind_host,
    mysql_module        => '2.2',
  }~> exec{'keystone db sync':
    command  => 'keystone-manage db_sync',
    path     => '/usr/bin',
  }

  class { '::keystone::roles::admin':
    email        => $::openstack::config::keystone_admin_email,
    password     => $::openstack::config::keystone_admin_password,
    admin_tenant => 'admin',
  }
}
