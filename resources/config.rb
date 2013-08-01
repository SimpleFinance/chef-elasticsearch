actions :create, :destroy
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :instance, kind_of: String, required: true
attribute :config_type, kind_of: String, equal_to: %w(elasticsearch logging)
attribute :config_options, kind_of: Hash
