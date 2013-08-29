require 'date'
require 'net/http'
require 'uri'
require 'chef/resource/execute'
require 'chef/resource/directory'
require 'chef/resource/remote_file'

require_relative 'helpers'

class Elasticsearch
  class Instance
    class Tar

      include Helprs::Elasticsearch

      def initialize(new_resource, run_context=nil)
        @new_resource = new_resource
        @run_context = run_context
        @source_file_res = set_source_file_resource
        @extract_res = set_extract_resource
        @inst_dir_res = set_installation_dir_resource
        @user = @new_resource.user
        @group = @new_resource.group
      end

      def create
        manage_source_file(:create)
        manage_directory(@inst_dir_res , :create)
        manage_extract_file(:run)
      end

      def destroy
        manage_source_file(:delete)
      end

      private

      def set_source_file_resource
        Chef::Resource::RemoteFile.new(file_name, @run_context)
      end

      def set_extract_resource
        Chef::Resource::Execute.new(source_file, @run_context)
      end

      def set_installation_dir_resource
        Chef::Resource::Directory.new(instance_installation_dir, @run_context)
      end

      def manage_source_file(action)
        @source_file_res.path source_file
        @source_file_res.source remote_file_location
        @source_file_res.user @user
        @source_file_res.group @group
        @source_file_res.mode 00644
        @source_file_res.run_action(action)
      end

      # HACK: Really dislike the execute resource.
      def manage_extract_file(action)
        @extract_res.user 'root'
        @extract_res.path %w(/bin /sbin /usr/bin /usr/sbin)
        @extract_res.command tar_command
        @extract_res.creates instance_binary
        @extract_res.returns 0
        @extract_res.timeout 180
        @extract_res.run_action(action)
      end

      def instance_installation_dir
        ::File.join('', instance_destination_dir, version)
      end

      def source_file
        ::File.join('', Chef::Config[:file_cache_path], file_name)
      end

      def tar_command
        "tar xaf #{ source_file } --owner #{ @user } --group #{ @group }\
        --strip-components=1 -C #{ instance_installation_dir }\
        --exclude='config/elasticsearch.yml' --exclude='config/logging.yml'"
      end

      def file_name
        "elasticsearch-#{ version }.tar.gz"
      end

      def remote_file_location
        "#{ url }/#{ file_name }"
      end

      def version
        @new_resource.install_options[:version]
      end

      def url
        @new_resource.install_options[:url]
      end

    end
  end
end
