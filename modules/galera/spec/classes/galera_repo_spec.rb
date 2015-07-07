require 'spec_helper'

describe 'galera::repo' do
  let :params do
    {
      :repo_vendor                   => 'percona',
      :epel_needed                   => true,

      :apt_percona_repo_location     => 'http://repo.percona.com/apt/',
      :apt_percona_repo_release      => 'precise',
      :apt_percona_repo_repos        => 'main',
      :apt_percona_repo_key          => '1C4CBDCDCD2EFD2A',
      :apt_percona_repo_key_server   => 'keys.gnupg.net',
      :apt_percona_repo_include_src  => false,

      :apt_mariadb_repo_location     => 'http://mirror.aarnet.edu.au/pub/MariaDB/repo/5.5/ubuntu',
      :apt_mariadb_repo_release      => 'precise',
      :apt_mariadb_repo_repos        => 'main',
      :apt_mariadb_repo_key          => '1BB943DB',
      :apt_mariadb_repo_key_server   => 'keys.gnupg.net',
      :apt_mariadb_repo_include_src  => false,

      :yum_percona_descr             => "CentOS 6 - Percona",
      :yum_percona_baseurl           => "http://repo.percona.com/centos/os/6/x86_64/",
      :yum_percona_gpgkey            => 'http://www.percona.com/downloads/percona-release/RPM-GPG-KEY-percona',
      :yum_percona_enabled           => 1,
      :yum_percona_gpgcheck          => 1,

      :yum_mariadb_descr             => 'MariaDB Yum Repo',
      :yum_mariadb_enabled           => 1,
      :yum_mariadb_gpgcheck          => 1,
      :yum_mariadb_gpgkey            => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
    }
  end

  let :pre_condition do
    "class { 'galera':
      configure_repo => false,
    }"
  end

  context 'on RedHat' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    context 'installing percona on redhat' do
      before { params.merge!( :repo_vendor => 'percona' ) }
      it { should contain_yumrepo('percona').with(
        :descr      => params[:yum_percona_descr],
        :enabled    => params[:yum_percona_enabled],
        :gpgcheck   => params[:yum_percona_gpgcheck],
        :gpgkey     => params[:yum_percona_gpgkey]
      ) }
    end

    context 'installing mariadb on redhat' do
      before { params.merge!( :repo_vendor => 'mariadb' ) }
      it { should contain_yumrepo('mariadb').with(
        :descr      => params[:yum_mariadb_descr],
        :enabled    => params[:yum_mariadb_enabled],
        :gpgcheck   => params[:yum_mariadb_gpgcheck],
        :gpgkey     => params[:yum_mariadb_gpgkey]
      ) }
    end
  end

  context 'on Ubuntu' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'precise'
      }
    end

    context 'installing percona on debian' do
      before { params.merge!( :repo_vendor => 'percona' ) }
      it { should contain_apt__source('galera_percona_repo').with(
        :location      => params[:apt_percona_repo_location],
        :release       => params[:apt_percona_repo_release],
        :repos         => params[:apt_percona_repo_repos],
        :key           => params[:apt_percona_repo_key],
        :key_server    => params[:apt_percona_repo_key_server],
        :include_src   => params[:apt_percona_repo_include_src]
      ) }
    end

    context 'installing mariadb on debian' do
      before { params.merge!( :repo_vendor => 'mariadb' ) }
      it { should contain_apt__source('galera_mariadb_repo').with(
        :location      => params[:apt_mariadb_repo_location],
        :release       => params[:apt_mariadb_repo_release],
        :repos         => params[:apt_mariadb_repo_repos],
        :key           => params[:apt_mariadb_repo_key],
        :key_server    => params[:apt_mariadb_repo_key_server],
        :include_src   => params[:apt_mariadb_repo_include_src]
      ) }
    end
  end
end
