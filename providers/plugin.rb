require 'chef/provider'
require_relative 'plugin_manual'
require_relative 'plugin_installer'

class Chef
  class Provider
    class ElasticsearchPlugin
      def initialize(new_resource, run_context)
        @new_resource = new_resource
        @run_context = run_context
        @instance = lookup_instance(@new_resource.instance, @run_context)
        @version = @new_resource.install_options[:version]
        @install_options = @new_resource.install_options
        @plugin = @new_resource.plugin
        @plugin_res = set_plugin_resource
        @source_file_res = set_source_file_resource
      end

      def whyrun_supported?
        false
      end

      # TODO: Write me!
      def load_current_resource
      end

      def action_create
        create_dst_dir
        instance(@new_resource.install_type, 'install')
      end

      def action_destroy
        instance(@new_resource.install_type, 'disable')
      end

      private

    end
  end
end
