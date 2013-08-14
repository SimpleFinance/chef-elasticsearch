#es_test/0.90.2/bin$ ./plugin
#Usage:
#    -u, --url     [plugin location]   : Set exact URL to download the plugin from
#    -i, --install [plugin name]       : Downloads and installs listed plugins [*]
#    -r, --remove  [plugin name]       : Removes listed plugins
#    -l, --list                        : List installed plugins
#    -v, --verbose                     : Prints verbose messages
#    -h, --help                        : Prints this help message
#
#    [*] Plugin name could be:
#    elasticsearch/plugin/version for official elasticsearch plugins (download from download.elasticsearch.org)
#    groupId/artifactId/version   for community plugins (download from maven central or oss sonatype)
#    username/repository          for site plugins (download from github master)

module Elasticsearch
  class PluginInstaller
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

    def action_create
      manage_plugin_install('install', :run)
    end

    def action_destroy
      manage_plugin_install('remove', :run)
    end

    private

    def set_plugin_resource
      Chef::Resource::Execute.new(@plugin, @run_context)
    end

    def manage_plugin_install(inst_action, run_action)
      @plugin_res.user @instance.user
      @plugin_res.path %w(/bin /sbin /usr/bin /usr/sbin)
      @plugin_res.command plugin_manage_command(inst_action)
      @plugin_res.creates plugin_install_creates
      @plugin_res.returns 0
      @plugin_res.timeout 180
      @plugin_res.run_action(run_action)
    end

    def instance_installation_dir
      ::File.join('', @instance.destination_dir, @instance.name, @instance.install_options[:version])
    end

    def plugin_command
      ::File.join('', instance_installation_dir, 'bin', 'plugin')
    end

    def url
      @new_resource.install_options[:url]
    end

    def plugin_manage_command(action)
      "#{ plugin_command } --#{ action } #{ plugin_install_name }"
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

    def plugin_install_name
      options = @install_options

      if options.has_key?(:groupId) && options.has_key?(:artifactId)
        "#{ options[:groupId] }/#{ options[:artifactId] }/#{ options[:version] }"
      elsif options.has_key?(:username) && options.has_key?(:repository)
        "#{ options[:username] }/#{ options[:repository] }"
      elsif options.has_key?(:url)
        options[:url]
      else
        "elasticsearch/#{ @plugin }/#{ options[:version] }"
      end
    end

    def lookup_resource(type, name, run_context)
      begin
        run_context.resource_collection.find("#{ type }[#{ name }]")
      rescue ArgumentError => e
        puts "You provided invalid arugments to resource_collection.find: #{ e }"
      rescue RuntimeError => e
        puts "The resources you searched for were not found: #{ e }"
      end
    end

    def lookup_instance(name, run_context)
      lookup_resource(:elasticsearch_instance, name, run_context)
    end
  end
end
