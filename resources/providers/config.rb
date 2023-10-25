# Cookbook Name:: rbale
#
# Provider:: config
#
action :add do
  begin
    config_dir = new_resource.config_dir
    ale_nodes = new_resource.ale_nodes

    dnf_package "redborder-ale" do
      action :upgrade
      flush_cache[:before]
    end

    dnf_package "zeromq-devel" do
      action :upgrade
      flush_cache[:before]
    end

    directory config_dir do #/etc/redborder-ale
      owner "redborder-ale"
      group "redborder-ale"
      mode '700'
      action :create
    end

    execute "scan_aps_ale" do
      ignore_failure true
      command "rvm ruby-2.7.5@web do /usr/bin/rb_scan_ale.rb; exit 0"
      action :nothing
      notifies :restart, "service[redborder-ale]", :delayed
    end

    template "/etc/redborder-ale/config.yml" do
      source "rb-ale_config.yml.erb"
      owner "root"
      group "root"
      mode 0644
      retries 2
      cookbook "rbale"
      variables(:ale_nodes => ale_nodes)
      notifies :run, 'execute[scan_aps_ale]', :delayed
      notifies :restart, "service[redborder-ale]", :delayed
  end

  service "redborder-ale" do
      service_name "redborder-ale"
      ignore_failure true
      supports :status => true, :reload => true, :restart => true
      action [:enable, :start]
  end

    Chef::Log.info("cookbook redborder-ale has been processed.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service "redborder-ale" do
      service_name "redborder-ale"
      supports :status => true, :restart => true, :start => true, :enable => true, :disable => true
      action [:disable, :stop]
    end
    Chef::Log.info("cookbook redborder-ale has been processed.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


action :register do #Usually used to register in consul
  begin
    if !node["rb-ale"]["registered"]
      query = {}
      query["ID"] = "rb-ale-#{node["hostname"]}"
      query["Name"] = "rb-ale"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 7779
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal["rb-ale"]["registered"] = true
    end
    Chef::Log.info("rb-ale service has been registered in consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do #Usually used to deregister from consul
  begin
    if node["rb-ale"]["registered"]
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/rb-ale-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal["rb-ale"]["registered"] = false
    end
    Chef::Log.info("rb-ale service has been deregistered from consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end
