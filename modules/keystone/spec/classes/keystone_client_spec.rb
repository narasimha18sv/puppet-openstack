require 'spec_helper'

describe 'keystone::client' do

  describe "with default parameters" do
    it { should contain_package('python-keystoneclient').with(
        'ensure' => 'present',
        'tag'    => 'openstack'
    ) }
  end

  describe "with specified version" do
    let :params do
      {:ensure => '2013.1'}
    end

    it { should contain_package('python-keystoneclient').with(
        'ensure' => '2013.1',
        'tag'    => 'openstack'
    ) }
  end
end
