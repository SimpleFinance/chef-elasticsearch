require 'json'
require_relative 'helpers'

class Chef
  class Provider
    class ElasticsearchConfig < Chef::Provider

      include Helpers::Elasticsearch

      def initialize(new_resource, run_context=nil)
        super
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

      def action_create
        manage_config_file(:create)
      end

      def action_destroy
        manage_config_file(:delete)
      end

      private

      def conf_file_res
        @conf_file_res ||= set_configuration_file_resource
      end

      def set_configuration_file_resource
        Chef::Resource::File.new(config_file_name, @run_context)
      end

      def manage_config_file(action)
        conf_file_res.path config_file_with_dir
        conf_file_res.content pretty_json_config
        conf_file_res.user @instance.user
        conf_file_res.group @instance.group
        conf_file_res.mode 00644
        conf_file_res.run_action(action)
      end

      def config_to_json
        JSON.parse(@new_resource.config_options.to_json)
      end

      def pretty_json_config
        JSON.pretty_generate(config_to_json)
      end

      def config_file_name
        "#{ @new_resource.config_type }.json"
      end

      def config_file_with_dir
        ::File.join('', instance_conf_dir, config_file_name)
      end

    end
  end
end
