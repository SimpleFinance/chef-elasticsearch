require 'chef/resource/service'
require 'chef/resource/template'

require_relative 'helpers'

class Elasticsearch
  class Instance
    class Init

      include Helprs::Elasticsearch

      def initialize(new_resource, run_context=nil)
        @new_resource = new_resource
        @run_context = run_context
        @init_res = set_service_init_resource
        @service_res = set_service_resource
        @user = @new_resource.user
        @group = @new_resource.group
      end

      def create
        manage_service_init(:create)
      end

      def enable
        manage_service(:enable)
      end

      def start
        manage_service(:start)
      end

      def update
        manage_service(:restart)
      end

      def disable
        manage_service(:disable)
      end

      def stop
        manage_service(:stop)
      end

      private

      def set_service_init_resource
        Chef::Resource::Template.new(@new_resource.name, @run_context)
      end

      def set_service_resource
        Chef::Resource::Service.new(@new_resource.name, @run_context)
      end

      # FIXME: Allow overriding the init erb.
      def manage_service_init(action)
        @init_res.path init_file
        @init_res.source 'elasticsearch-init.erb'
        @init_res.cookbook 'elasticsearch'
        @init_res.owner @user
        @init_res.group @group
        @init_res.mode 00755
        @init_res.variables({
          bin_path: instance_binary,
          pid_file: instance_pid,
          name: @new_resource.name,
          user: @user
        })
        @init_res.run_action(action)
      end

      def manage_service(action)
        @service_res.run_action(action)
      end

      # FIXME: This currently assumes '/etc/init.d'
      # FIXME: We're forcing the leader name 'elasticsearch-'
      def init_file
        ::File.join('', '/etc/init.d', "elasticsearch-#{ @new_resource.name }")
      end

      # FIXME: This currently assumes _we_ installed ES.
      # FIXME: We should get this from the instance resource.
      def instance_binary
        ::File.join('', instance_installation_dir, 'bin', 'elasticsearch')
      end

    end
  end
end
