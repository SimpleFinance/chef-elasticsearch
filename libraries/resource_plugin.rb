require 'chef/resource'

class Chef
  class Resource
    class ElasticsearchPlugin < Chef::Resource
      def initialize
        super
        @resource_name = :elasticsearch_plugin
        @provider = Chef::Provider::ElasticsearchPlugin
        @allowed_actions = [:install, :remove]
        @action = :install
      end

      def instance(arg = nil)
        set_or_return(:instance,
                      arg,
                      kind_of: String,
                      required: true)
      end

      def plugin(arg = nil)
        set_or_return(:plugin,
                      arg,
                      kind_of: String,
                      name_attribute: true)
      end

      def plugin_timeout(arg = nil)
        set_or_return(:plugin_timeout,
                      arg,
                      kind_of: Fixnum,
                      default: 300)
      end

      def install_options(arg = nil)
        set_or_return(:install_options,
                      arg,
                      kind_of: Hash)
      end

      def install_type(arg = nil)
        set_or_return(:install_type,
                      arg,
                      kind_of: Symbol,
                      equal_to: [:manual, :plugin])
      end
    end
  end
end