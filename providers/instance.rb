
def initialize(new_resource, run_context)
  super
  @new_resource = new_resource
  @user = @new_resource.user
  @group = @new_resource.group
  @user_res = set_user_resource
  @group_res = set_group_resource
  @service_res = set_service_resource
  @init_res = set_service_init_resource
  @conf_dir_res = set_configuration_dir_resource
  @dest_dir_res = set_destination_dir_resource
  @inst_dir_res = set_installation_dir_resource
  @source_file_res = set_source_file_resource
  @extract_res = set_extract_resource
end

action :create do
  manage_user(:create)
  manage_group(:create)

  [@dest_dir_res, @conf_dir_res, @inst_dir_res].each do |dir|
    manage_directory(dir , :create)
  end

  manage_source_file(:create)
  manage_extract_file(:run)
  manage_service_init(:create)
end

action :enable do
  manage_service(:enable)
end

action :destroy do
  [@dest_dir_res, @conf_dir_res].each do |dir|
    manage_directory(dir, :delete)
  end

  manage_user(:remove)
  manage_group(:remove)
  manage_source_file(:delete)
end

action :disable do
  manage_service(:disable)
end

private

def set_user_resource
  Chef::Resource::User.new(@user, @run_context)
end

def set_group_resource
  Chef::Resource::Group.new(@group, @run_context)
end

def set_service_resource
  Chef::Resource::Service.new(@new_resource.name, @run_context)
end

def set_service_init_resource
  Chef::Resource::Template.new(@new_resource.name, @run_context)
end

def set_source_file_resource
  Chef::Resource::RemoteFile.new(file_name, @run_context)
end

def set_destination_dir_resource
  Chef::Resource::Directory.new(instance_destination_dir, @run_context)
end

def set_configuration_dir_resource
  Chef::Resource::Directory.new(instance_configuration_dir, @run_context)
end

def set_installation_dir_resource
  Chef::Resource::Directory.new(instance_installation_dir, @run_context)
end

def set_extract_resource
  Chef::Resource::Execute.new(source_file, @run_context)
end

def manage_user(action)
  @user_res.system true
  @user_res.run_action(action)
end

def manage_group(action)
  @group_res.system true
  @group_res.run_action(action)
end

def manage_directory(res, action)
  res.owner @user
  res.group @group
  res.recursive true
  res.mode 00755
  res.run_action(action)
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

def manage_service_init(action)
  @init_res.path init_file
  @init_res.source 'elasticsearch-init.erb'
  @init_res.cookbook 'elasticsearch'
  @init_res.owner @user
  @init_res.group @group
  @init_res.mode 00755
  @init_res.variables({
    bin_path: instance_binary,
    name: @new_resource.name,
    user: @user
  })
  @init_res.run_action(action)
end

def manage_service(action)
  @service.run_action(action)
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

def instance_installation_dir
  ::File.join('', instance_destination_dir, version)
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
  --strip-components=1 -C #{ instance_installation_dir }"
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
