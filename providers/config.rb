require 'json'

def initialize(new_resource, run_context=nil)
  super
  @new_resource = new_resource
  @run_context = run_context
  @instance = lookup_instance(@new_resource.instance, @run_context)
  @conf_file_res = set_configuration_file_resource
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

def config_file_name
  "#{ @new_resource.config_type }.json"
end

def config_file_with_dir
  ::File.join('', instance_conf_dir, config_file_name)
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
