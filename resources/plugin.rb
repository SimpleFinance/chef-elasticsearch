
actions :create, :enable, :destroy, :disable
default_action :create

attribute :instance, kind_of: String, required: true
attribute :plugin, kind_of: String, name_attribute: true
attribute :plugin_timeout, kind_of: Fixnum, default: 300
attribute :install_options, kind_of: Hash
