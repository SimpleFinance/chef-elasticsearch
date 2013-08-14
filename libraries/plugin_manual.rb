class Elasticsearch
  class Plugin
    class ManualCmd
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

      def install
        manage_plugin_install('install', :run)
      end

      def remove
        manage_plugin_install('remove', :run)
      end

      private

      def set_plugin_resource
        Chef::Resource::Execute.new(@plugin, @run_context)
      end

      def set_source_file_resource
        Chef::Resource::RemoteFile.new(file_name, @run_context)
      end

      def extract_plugin(run_action)
        @plugin_res.user @instance.user
        @plugin_res.path %w(/bin /sbin /usr/bin /usr/sbin)
        @plugin_res.command plugin_unzip_command
        @plugin_res.creates plugin_install_creates
        @plugin_res.returns 0
        @plugin_res.timeout 180
        @plugin_res.run_action(run_action)
      end

      def manage_source_file(action)
        @source_file_res.path source_file
        @source_file_res.source remote_file_location
        @source_file_res.user @user
        @source_file_res.group @group
        @source_file_res.mode 00644
        @source_file_res.run_action(action)
      end

      def instance_installation_dir
        ::File.join('', @instance.destination_dir, @instance.name, @instance.install_options[:version])
      end

      def plugin_unzip_command
        "#{ unzip } #{ compressed_plugin_file } -d #{ plugin_dir }"
      end

      # If for some reason unzip lives outside of @plugin_res.path
      def unzip
        @install_options[:unzip_path] || 'unzip'
      end

      def source_file
        ::File.join('', Chef::Config[:file_cache_path], file_name)
      end

      def url
        @new_resource.install_options[:url]
      end

      def file_name
        @install_options[:plugin_filename] || "#{ @plugin }-#{ @version }.zip"
      end

      def remote_file_location
        "#{ url }/#{ file_name }"
      end

      def plugin_install_creates
        @install_options[:plugin_creates] || plugin_dir
      end

      def plugin_dir
        ::File.join('', instance_plugin_dir, @plugin)
      end

      # TODO: Can we pull this from instance configuration?
      def instance_plugin_dir
        ::File.join('', instance_installation_dir, 'plugins')
      end
    end
  end
end
