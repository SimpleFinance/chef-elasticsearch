require 'chef/provider'

class Chef
  class Provider
    # The Elasticsearch Instance Chef Resource
    class ElasticsearchInstance < Chef::Provider
      def initialize(new_resource, run_context)
        super
        @new_resource = new_resource
        @run_context = run_context
        @user = @new_resource.user
        @group = @new_resource.group
      end

      def action_create
        manage_user(:create)
        manage_group(:create)

        [dest_dir_res, conf_dir_res, inst_dir_res].each do |dir|
          manage_directory(dir , :create)
        end

        manage_source_file(:create)
        manage_extract_file(:run)
        manage_plugin_directory(:create)
        manage_config_dir_link(:create)
        manage_env_vars_file(:create) unless @new_resource.service_options.nil?
        manage_service_init(:create)
      end

      def action_enable
        manage_service(:enable)
      end

      def action_start
        manage_service(:start)
      end

      def action_stop
        manage_service(:stop)
      end

      def action_restart
        manage_service(:restart)
      end

      def action_destroy
        [dest_dir_res, conf_dir_res, inst_dir_res].each do |dir|
          manage_directory(dir, :delete)
        end

        manage_user(:remove)
        manage_group(:remove)
        manage_source_file(:delete)
        manage_config_dir_link(:delete)
        manage_service_init(:delete)
      end

      def action_disable
        manage_service(:disable)
      end

      private

      def user_res
        @user_res ||=
            Chef::Resource::User.new(
                @user, @run_context
            )
      end

      def group_res
        @group_res ||=
            Chef::Resource::Group.new(
                @group, @run_context
            )
      end

      def service_res
        @service_res ||=
            Chef::Resource::Service.new(
                "elasticsearch-#{ @new_resource.name }", @run_context
            )
      end

      def init_res
        @init_res ||=
            Chef::Resource::Template.new(
                @new_resource.name, @run_context
            )
      end

      def service_env_vars_res
        @service_env_vars_res ||=
            Chef::Resource::Template.new(
                "#{@new_resource.name}_env_vars", @run_context
            )
      end

      def source_file_res
        @source_file_res ||=
            Chef::Resource::RemoteFile.new(
                file_name, @run_context
            )
      end

      def dest_dir_res
        @dest_dir_res ||=
            Chef::Resource::Directory.new(
                instance_destination_dir, @run_context
            )
      end

      def conf_dir_res
        @conf_dir_res ||=
            Chef::Resource::Directory.new(
                instance_configuration_dir, @run_context
            )
      end

      def inst_dir_res
        @inst_dir_res ||=
            Chef::Resource::Directory.new(
                instance_installation_dir, @run_context
            )
      end

      def link_res
        @link_res ||=
            Chef::Resource::Link.new(
                instance_installation_configuration_dir, @run_context
            )
      end

      def extract_res
        @extract_res ||=
            Chef::Resource::Execute.new(
                source_file, @run_context
            )
      end

      def plugin_dir_res
        @plugin_dir_res ||=
            Chef::Resource::Directory.new(
                plugin_dir, @run_context
            )
      end

      def manage_user(action)
        user_res.system true
        user_res.run_action(action)
      end

      def manage_group(action)
        group_res.system true
        group_res.run_action(action)
      end

      def manage_directory(res, action)
        res.owner @user
        res.group @group
        res.recursive true
        res.mode 00755
        res.run_action(action)
      end

      def manage_source_file(action)
        source_file_res.path source_file
        source_file_res.source remote_file_location
        source_file_res.user @user
        source_file_res.group @group
        source_file_res.mode 00644
        source_file_res.run_action(action)
      end

      # Fixme: Use mixlib-shellout directly.
      def manage_extract_file(action)
        extract_res.user 'root'
        extract_res.path %w(/bin /sbin /usr/bin /usr/sbin)
        extract_res.command tar_command
        extract_res.creates instance_binary
        extract_res.returns 0
        extract_res.timeout 180
        extract_res.run_action(action)
      end

      def manage_service_init(action)
        init_res.path init_file
        init_res.source 'elasticsearch-init.erb'
        init_res.cookbook 'elasticsearch'
        init_res.owner @user
        init_res.group @group
        init_res.mode 00755
        init_res.variables(
          bin_path: instance_binary,
          env_vars_file: instance_environment_vars_file,
          pid_file: "#{instance_installation_configuration_dir}" \
            "/elasticsearch-#{@new_resource.name}.pid",
          name: @new_resource.name,
          user: @user
        )
        init_res.run_action(action)
      end

      def manage_env_vars_file(action)
        service_env_vars_res.path instance_environment_vars_file
        service_env_vars_res.source 'environment_vars.erb'
        service_env_vars_res.cookbook 'elasticsearch'
        service_env_vars_res.owner @user
        service_env_vars_res.group @group
        service_env_vars_res.mode 00644
        service_env_vars_res.variables(
            service_options: @new_resource.service_options
        )
        service_env_vars_res.run_action(action)
      end

      def manage_config_dir_link(action)
        link_res.target_file instance_installation_configuration_dir
        link_res.to instance_configuration_dir
        link_res.owner @user
        link_res.group @group
        link_res.run_action(action)
      end

      def manage_plugin_directory(action)
        plugin_dir_res.path plugin_dir
        plugin_dir_res.user @user
        plugin_dir_res.group @group
        plugin_dir_res.recursive true
        plugin_dir_res.mode 00755
        plugin_dir_res.run_action(action)
      end

      def manage_service(action)
        service_res.run_action(action)
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

      def plugin_dir
        ::File.join('', instance_installation_dir, 'plugins')
      end

      def instance_environment_vars_file
        ::File.join('', instance_configuration_dir, 'environment_vars')
      end

      def instance_installation_dir
        ::File.join('', instance_destination_dir, version)
      end

      def instance_installation_configuration_dir
        ::File.join('', instance_installation_dir, 'config')
      end

      def instance_binary
        ::File.join('', instance_installation_dir, 'bin', 'elasticsearch')
      end

      def init_file
        ::File.join('', '/etc/init.d', "elasticsearch-#{ @new_resource.name }")
      end

      def source_file
        ::File.join('', Chef::Config[:file_cache_path], file_name)
      end

      def tar_command
        "tar xaf #{ source_file } --owner #{ @user } --group #{ @group }\
        --strip-components=1 -C #{ instance_installation_dir }\
        --exclude='config/elasticsearch.yml' --exclude='config/logging.yml'"
      end

      def version
        @new_resource.install_options[:version]
      end

      def url
        @new_resource.install_options[:url]
      end

      def file_name
        "elasticsearch-#{ version }.tar.gz"
      end

      def remote_file_location
        "#{ url }/#{ file_name }"
      end
    end
  end
end
