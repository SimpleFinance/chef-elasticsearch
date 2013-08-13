
def initialize(new_resource, run_context)
  @new_resource = new_resource
  @run_context = run_context
  @instance = lookup_instance(@new_resource.instance, @run_context)
  @source_file_res = set_source_file_resource
  @extract_res = set_extract_resource
end

action :create do
end

action :destroy do
end

private

def set_source_file_resource
  Chef::Resource::RemoteFile.new(file_name, @run_context)
end

def set_extract_resource
  Chef::Resource::Execute.new(source_file, @run_context)
end

def manage_extract_file(action)
  @extract_res.user 'root'
  @extract_res.path %w(/bin /sbin /usr/bin /usr/sbin)
  @extract_res.command tar_command
  @extract_res.creates instance_binary
  @extract_res.returns 0
  @extract_res.timeout 180
  @extract_res.run_action(action)
end

def manage_source_file(action)
  @source_file_res.path source_file
  @source_file_res.source remote_file_location
  @source_file_res.user @user
  @source_file_res.group @group
  @source_file_res.mode 00644
  @source_file_res.run_action(action)
end

def source_file
  ::File.join('', Chef::Config[:file_cache_path], file_name)
end

def unzip_command
  "unzip #{ source_file }"
end

def instance_binary
  ::File.join('', instance_installation_dir, 'bin', 'elasticsearch')
end

def remote_file_location
  "#{ url }/#{ file_name }"
end

def url
  @new_resource.install_options[:url]
end

def file_name
  "elasticsearch-#{ version }.tar.gz"
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
