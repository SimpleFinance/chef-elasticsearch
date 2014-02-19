require 'chef/resource'

class Chef
  class Resource
    class ElasticsearchInstance < Chef::Resource
      def initialize
        super
        @resource_name = :elasticsearch_instance
        @provider = Chef::Provider::ElasticsearchInstance
        @action = :create
        @allowed_actions = [
          :create,
          :enable,
          :destroy,
          :disable,
          :start,
          :stop,
          :restart
        ]
      end

      def user(arg = nil)
        set_or_return(:user,
                      arg,
                      kind_of: String,
                      default: 'elasticsearch')
      end

      def group(arg = nil)
        set_or_return(:group,
                      arg,
                      kind_of: String,
                      default: 'elasticsearch')
      end

      def destination_dir(arg = nil)
        set_or_return(:destination_dir,
                      arg,
                      kind_of: String,
                      default: ::File.join('', 'opt', 'elasticsearch'))
      end

      def configuration_dir(arg = nil)
        set_or_return(:configuration_dir,
                      arg,
                      kind_of: String)
      end

      def install_options(arg = nil)
        set_or_return(:install_options,
                      arg,
                      kind_of: Hash)
      end

      def service_options(arg = nil)
        set_or_return(:service_options,
                      arg,
                      kind_of: Hash)
      end

      def install_type(arg = nil)
        set_or_return(:install_type,
                      arg,
                      kind_of: [Symbol, String],
                      equal_to: [:tgz, 'tgz', :package, 'package'],
                      default: :tgz)
      end

      def service_type(arg = nil)
        set_or_return(:service_type,
                      arg,
                      kind_of: [Symbol, String],
                      equal_to: [:init, 'init', :runit, 'runit'],
                      default: :init)
      end
    end
  end
end