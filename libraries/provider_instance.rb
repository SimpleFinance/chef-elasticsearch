class Chef
  class Provider
    class ElasticsearchInstance < Chef::Provider

      def initialize(new_resource, run_context)
        super
        @new_resource = new_resource
        @run_context = run_context
      end

      def whyrun_supported?
        false
      end

      def load_current_resource
      end

      def action_create
        instance(@new_resource.install_type, 'create')
        instance(@new_resource.service_type, 'create')
        @new_resource.updated_by_last_action(true)
      end

      def action_enable
        instance(@new_resource.service_type, 'enable')
        @new_resource.updated_by_last_action(true)
      end

      def action_destroy
        instance(@new_resource.service_type, 'destroy')
        @new_resource.updated_by_last_action(true)
      end

      def action_disable
        instance(@new_resource.install_type, 'disable')
        @new_resource.updated_by_last_action(true)
      end

      private

      def instance(type, action)
        instance_class = instance_sub_class(type)
        i = instance_class.new(@new_resource, @run_context)
        i.send(action)
      end

      def instance_sub_class(type)
        klass = "Elasticsearch::Instance::#{ type.capitalize }"
        klass.split('::').reduce(Object) { |kls, t| kls.const_get(t) }
      end

    end
  end
end
