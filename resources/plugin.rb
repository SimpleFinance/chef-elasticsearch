
actions :create, :enable, :destroy, :disable
default_action :create

default_install_options = { url: 'https://oss-es-plugins.s3.amazonaws.com',
                            version: ''}

attribute :archive, kind_of: String, equal_to: archive_types, default: 'zip'
attribute :instance, kind_of: String, required: true
attribute :plugin, kind_of: String, name_attribute: true
attribute :plugin_timeout, kind_of: Fixnum, default: 300
#
# TODO
# Should probably callback and merge user supplied with default
# to allow selective overrides of hash options.
attribute :install_options, kind_of: Hash, default: default_install_options
