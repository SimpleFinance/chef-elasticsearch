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

    action :create do
      manage_config_file(:create)
    end

    action :destroy do
      manage_config_file(:delete)
    end

    private

    def set_configuration_file_resource
      Chef::Resource::File.new(config_file_name, @run_context)
    end

    def manage_config_file(action)
      @conf_file_res.path config_file_with_dir
      @conf_file_res.content pretty_json_config
      @conf_file_res.user @instance.user
      @conf_file_res.group @instance.group
      @conf_file_res.mode 00644
      @conf_file_res.run_action(action)
    end

    def config_to_json
      JSON.parse(@new_resource.config_options.to_json)
    end

    def pretty_json_config
      JSON.pretty_generate(config_to_json)
    end
  end
end
