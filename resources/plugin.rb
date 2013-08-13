
actions :create, :enable, :destroy, :disable
default_action :create

attribute :instance, kind_of: String, required: true
attribute :plugin, kind_of: String, name_attribute: true
attribute :plugin_timeout, kind_of: Fixnum, default: 300
#
# TODO
# Should probably callback and merge user supplied with default
# to allow selective overrides of hash options.
attribute :install_options, kind_of: Hash
