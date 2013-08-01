require 'json'

def initialize(new_resource, run_context=nil)
  super
  @new_resource = new_resource
  @run_context = run_context
  @user = @new_resource.user
  @group = @new_resource.group
  @conf_file_res = set_configuration_file_resource
  @instance = lookup_instance(@new_resource.name, @run_context)
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
  @conf_file_res.content config_to_json
  @conf_file_res.user @user
  @conf_file_res.group @group
  @conf_file_res.mode 00644
  @conf_file_res.run_action(action)
end

def config_to_json
  @new_resource.config_options.to_json
end

def lookup_instance_conf_dir
  @instance.configuration_dir
end

def config_file_name
  "#{ @new_resource.config_type }.json"
end

def conf_file_with_dir
  ::File.join('', lookup_instance_conf_dir, config_file_name)
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
