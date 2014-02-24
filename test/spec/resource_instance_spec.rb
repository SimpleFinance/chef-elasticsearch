require_relative 'spec_helper'
require_relative '../../libraries/resource_elasticsearch_instance'
require_relative '../../libraries/provider_elasticsearch_instance'

describe 'ResourceElasticsearchInstance',
         'Tests for Chef::Resource::ElasticsearchInstance' do

  let(:node) do
    node = Chef::Node.new
    node.automatic['platform'] = 'ubuntu'
    node.automatic['platform_version'] = '12.04'
    node
  end
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:instance_name) { 'test_instance' }
  let(:elasticsearch_instance) do
    Chef::Resource::ElasticsearchInstance.new(instance_name, run_context)
  end

  before :each do
    @elasticsearchinstance = elasticsearch_instance
  end

  describe 'Chef Resource Checks for Chef::Resource::ElasticsearchInstance' do
    it 'Is a Chef::Resource?' do
      assert_kind_of(Chef::Resource, @elasticsearchinstance)
    end

    it 'Is a instance of ElasticsearchInstance' do
      assert_instance_of(Chef::Resource::ElasticsearchInstance,
                         @elasticsearchinstance)
    end
  end

  describe 'Parameter tests for Chef::Resource::ElasticsearchInstance' do
    it "has a 'user' parameter that can be set" do
      assert_respond_to(@elasticsearchinstance, :user)
      @elasticsearchinstance.user('user')
      assert(@elasticsearchinstance.user, 'user')
    end

    it "has a 'group' parameter that can be set" do
      assert_respond_to(@elasticsearchinstance, :group)
      @elasticsearchinstance.group('group')
      assert(@elasticsearchinstance.group, 'group')
    end

    describe 'Installation related parameters.' do
      it "'install_type' can be set to :tgz" do
        assert_respond_to(@elasticsearchinstance, :install_type)
        @elasticsearchinstance.install_type(:tgz)
        assert(@elasticsearchinstance.install_type, :tgz)
      end

      it "'install_type' can be set to 'tgz'" do
        assert_respond_to(@elasticsearchinstance, :install_type)
        @elasticsearchinstance.install_type('tgz')
        assert(@elasticsearchinstance.install_type, 'tgz')
      end

      it "'install_type' can be set to 'package'" do
        assert_respond_to(@elasticsearchinstance, :install_type)
        @elasticsearchinstance.install_type('package')
        assert(@elasticsearchinstance.install_type, 'package')
      end

      it "'install_type' can be set to :package" do
        assert_respond_to(@elasticsearchinstance, :install_type)
        @elasticsearchinstance.install_type(:package)
        assert(@elasticsearchinstance.install_type, :package)
      end

      describe "'install_options' parameter." do
        it 'allows hash like objects' do
          test_instance = {
              format: 'plain',
              path: %w(/var/log/httpd/*_log),
              type: 'httpd'
          }
          @elasticsearchinstance.install_options(test_instance)
          assert(@elasticsearchinstance.install_options, 'input')
        end

        it 'doesnt allow other types of objects.' do
          assert_raises(Chef::Exceptions::ValidationFailed) do
            @elasticsearchinstance.install_options(%w(foo bar baz))
          end

          assert_raises(Chef::Exceptions::ValidationFailed) do
            @elasticsearchinstance.install_options('foobarbaz')
          end
        end
      end
    end

    describe 'Service related parameters.' do
      describe "'service_options' parameter." do
        it 'allows hash like objects' do
          test_instance = {
              format: 'plain',
              path: %w(/var/log/httpd/*_log),
              type: 'httpd'
          }
          @elasticsearchinstance.service_options(test_instance)
          assert(@elasticsearchinstance.service_options, 'input')
        end

        it 'doesnt allow other types of objects.' do
          assert_raises(Chef::Exceptions::ValidationFailed) do
            @elasticsearchinstance.install_options(%w(foo bar baz))
          end

          assert_raises(Chef::Exceptions::ValidationFailed) do
            @elasticsearchinstance.install_options('foobarbaz')
          end
        end
      end

      describe "'service_type' parameter." do
        it "'service_type' can be set to :init" do
          assert_respond_to(@elasticsearchinstance, :service_type)
          @elasticsearchinstance.service_type(:init)
          assert(@elasticsearchinstance.service_type, :init)
        end

        it "'service_type' can be set to :runit" do
          assert_respond_to(@elasticsearchinstance, :service_type)
          @elasticsearchinstance.service_type(:runit)
          assert(@elasticsearchinstance.service_type, :runit)
        end

        it "'service_type' can be set to 'init'" do
          assert_respond_to(@elasticsearchinstance, :service_type)
          @elasticsearchinstance.service_type('init')
          assert(@elasticsearchinstance.service_type, 'init')
        end

        it "'service_type' can be set to 'runit'" do
          assert_respond_to(@elasticsearchinstance, :service_type)
          @elasticsearchinstance.service_type('runit')
          assert(@elasticsearchinstance.service_type, 'runit')
        end
      end
    end
  end
end
