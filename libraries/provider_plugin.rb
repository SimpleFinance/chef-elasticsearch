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
        @instance = lookup_instance(@new_resource.instance, @run_context)
      end

      # TODO: Add me!
      def whyrun_supported?
        false
      end

      # TODO: Write me!
      def load_current_resource
      end

      def action_install
        manage_plugin_dir(:create)
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

      def plugin_dir_res
        @plugin_dir_res ||= set_plugin_dir_resource
      end

      def set_plugin_dir_resource
        Chef::Resource::Directory.new(instance_plugin_dir, @run_context)
      end

      def manage_plugin_dir(run_action)
        plugin_dir_res.owner @instance.user
        plugin_dir_res.group @instance.group
        plugin_dir_res.path instance_plugin_dir
        plugin_dir_res.mode 00755
        plugin_dir_res.run_action(run_action)
      end

      def instance_plugin_dir
        ::File.join('', instance_installation_dir, 'plugins')
      end

    end
  end
end
