
actions :create, :enable, :destroy, :disable, :start, :stop, :restart
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :user, kind_of: String, default: 'elasticsearch'
attribute :group, kind_of: String, default: 'elasticsearch'
attribute :destination_dir, kind_of: String, default: ::File.join('', 'opt', 'elasticsearch')

attribute :configuration_dir, kind_of: String
attribute :install_options, kind_of: Hash
attribute :service_options, kind_of: Hash
attribute :mlockall, kind_of: [TrueClass, FalseClass], default: true

attribute :install_type, kind_of: String,
  equal_to: %w(tgz package), default: 'tgz'

attribute :service_type, kind_of: String, equal_to: %w(init runit),
  default: 'init'
