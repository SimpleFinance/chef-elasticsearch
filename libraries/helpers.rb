module Helpers
  module Elasticsearch

    def instance_destination_dir
      ::File.join('', @instance.destination_dir, @instance.name)
    end

    def instance_conf_dir
      if @instance.configuration_dir.nil?
        ::File.join('', instance_destination_dir, 'conf')
      else
        @instance.configuration_dir
      end
    end

    def instance_installation_dir
      ::File.join('', @instance.destination_dir, @instance.name, @instance.install_options[:version])
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

    def instance_pid_dir
      ::File.join('', instance_destination_dir, 'pid')
    end

    def instance_pid
      ::File.join('', instance_pid_dir, "#{ @new_resource.name }.pid")
    end

    def manage_directory(res, action)
      res.owner @user
      res.group @group
      res.recursive true
      res.mode 00755
      res.run_action(action)
    end

  end
end
