
actions :install, :remove
default_action :install

attribute :instance, kind_of: String, required: true
attribute :plugin, kind_of: String, name_attribute: true
attribute :plugin_timeout, kind_of: Fixnum, default: 300
attribute :install_options, kind_of: Hash
attribute :install_type, kind_of: String, equal_to: %w(manual plugin)
