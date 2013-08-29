require 'chef/resource/file'
require 'chef/resource/directory'

require_relative 'helpers'

class Elasticsearch
  class Instance
    class Dir

      include Helprs::Elasticsearch

      def initialize(new_resource, run_context=nil)
        @new_resource = new_resource
        @run_context = run_context
        @conf_dir_res = set_configuration_dir_resource
        @link_res = set_config_dir_link_resource
        @dest_dir_res = set_destination_dir_resource
        @pid_dir_res = set_pid_dir_resource
        @user = @new_resource.user
        @group = @new_resource.group
      end

      def create
        [@dest_dir_res, @conf_dir_res, @pid_dir_res, @inst_dir_res].each do |dir|
          manage_directory(dir , :create)
        end
        manage_config_dir_link(:create)
      end

      def destroy
        [@dest_dir_res, @conf_dir_res, @inst_dir_res].each do |dir|
          manage_directory(dir, :delete)
        end
        manage_config_dir_link(:delete)
      end

      private

      def set_destination_dir_resource
        Chef::Resource::Directory.new(instance_destination_dir, @run_context)
      end

      def set_pid_dir_resource
        Chef::Resource::Directory.new(instance_pid_dir, @run_context)
      end

      def set_configuration_dir_resource
        Chef::Resource::Directory.new(instance_configuration_dir, @run_context)
      end

      def set_config_dir_link_resource
        Chef::Resource::Link.new(instance_installation_configuration_dir, @run_context)
      end

      def manage_config_dir_link(action)
        @link_res.target_file instance_installation_configuration_dir
        @link_res.to instance_configuration_dir
        @link_res.owner @user
        @link_res.group @group
        @link_res.run_action(action)
      end

      def instance_destination_dir
        ::File.join('', @new_resource.destination_dir, @new_resource.name)
      end

      def instance_configuration_dir
        if @new_resource.configuration_dir.nil?
          ::File.join('', instance_destination_dir, 'conf')
        else
          @new_resource.configuration_dir
        end
      end

      def instance_installation_configuration_dir
        ::File.join('', instance_installation_dir, 'config')
      end

    end
  end
end
