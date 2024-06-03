# Cookbook:: rbale
# Recipe:: default
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

rbale_config 'config' do
  name node['hostname']
  action :add
end
