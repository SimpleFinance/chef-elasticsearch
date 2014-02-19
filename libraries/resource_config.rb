require 'chef/resource'

class Chef
  class Resource
    class ElasticsearchConfig < Chef::Resource

      def initialize
        super
        @resource_name = :elasticsearch_config
        @provider = Chef::Provider::ElasticsearchConfig
        @action = :create
        @allowed_actions = [:create, :destroy]
      end

      def instance(arg = nil)
        set_or_return(:instance,
                      arg,
                      kind_of: [String])
      end

      def config_type(arg = nil)
        set_or_return(:config_type,
                      arg,
                      kind_of: [Symbol, String])
      end

      def config_options(arg = nil)
        set_or_return(:config_options,
                      arg,
                      kind_of: [Hash])
      end

    end
  end
end