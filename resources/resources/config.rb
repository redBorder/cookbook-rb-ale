# Cookbook:: rbale
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :config_dir, kind_of: String, default: '/etc/redborder-ale'
attribute :name, kind_of: String, default: 'localhost'
attribute :ip, kind_of: String, default: '127.0.0.1'
attribute :ale_nodes, kind_of: Array, default: []
