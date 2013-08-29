require 'chef/resource/file'
require 'chef/resource/directory'

require_relative 'helpers'

class Elasticsearch
  class Instance
    class User

      include Helprs::Elasticsearch

      def initialize(new_resource, run_context=nil)
        @new_resource = new_resource
        @run_context = run_context
        @user = @new_resource.user
        @group = @new_resource.group
        @user_res = set_user_resource
        @group_res = set_group_resource
      end

      def create
        manage_user(:create)
        manage_group(:create)
      end

      def destroy
        manage_user(:remove)
        manage_group(:remove)
      end

      private

      def set_user_resource
        Chef::Resource::User.new(@user, @run_context)
      end

      def set_group_resource
        Chef::Resource::Group.new(@group, @run_context)
      end

      def manage_user(action)
        @user_res.system true
        @user_res.run_action(action)
      end

      def manage_group(action)
        @group_res.system true
        @group_res.run_action(action)
      end

    end
  end
end
