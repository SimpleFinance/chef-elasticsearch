require 'chef/provider'
require_relative 'plugin_manual'
require_relative 'plugin_installer'
require_relative 'helpers'

class Chef
  class Provider
    class ElasticsearchPlugin < Chef::Provider

      include Helpers::Elasticsearch

      def initialize(new_resource, run_context)
        @new_resource = new_resource
        @run_context = run_context
      end

      # TODO: Add me!
      def whyrun_supported?
        false
      end

      # TODO: Write me!
      def load_current_resource
      end

      def action_install
        instance(@new_resource.install_type, 'install')
      end

      def action_remove
        instance(@new_resource.install_type, 'remove')
      end

      private

      def instance(type, action)
        instance_class = instance_sub_class(type)
        i = instance_class.new(@new_resource, @run_context)
        i.send(action)
      end

      def instance_sub_class(type)
        klass = "Elasticsearch::Plugin::#{ type.capitalize }Cmd"
        klass.split('::').reduce(Object) { |kls, t| kls.const_get(t) }
      end

    end
  end
end
