#
# Cookbook Name:: rbale
# Recipe:: default
#
# redborder
#
#

rbale_config "config" do
  name node["hostname"]
  action :add
end
