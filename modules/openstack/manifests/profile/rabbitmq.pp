# The profile to install rabbitmq and set the firewall

class openstack::profile::rabbitmq {

  if $::osfamily == 'RedHat' {
    package { 'erlang':
      ensure  => installed,
      before  => Package['rabbitmq-server'],
      require => Yumrepo['erlang-solutions'],
    }
  }

  rabbitmq_user { $::openstack::config::rabbitmq_user:
    admin    => true,
    password => $::openstack::config::rabbitmq_password,
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { "${openstack::config::rabbitmq_user}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }->Anchor<| title == 'nova-start' |>

  class { '::rabbitmq':
    service_ensure           => 'running',
    port                     => 5672,
    config_cluster           => true,
    cluster_nodes            => $::openstack::config::rabbitmq_cluster,
    cluster_node_type        => 'ram',
    erlang_cookie            => 'password123',
    wipe_db_on_cookie_change => true,
    delete_guest_user        => true,
    cluster_partition_handling => autoheal,
  }
}
