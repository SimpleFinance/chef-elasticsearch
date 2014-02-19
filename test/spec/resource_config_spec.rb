
require_relative 'spec_helper'
require_relative '../../libraries/resource_elasticsearch_config'
require_relative '../../libraries/provider_elasticsearch_config'

describe 'ResourceElasticsearchConfig',
         'Tests for Chef::Resource::ElasticsearchConfig' do

  let(:node) do
    node = Chef::Node.new
    node.automatic['platform'] = 'ubuntu'
    node.automatic['platform_version'] = '12.04'
    node
  end
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:instance_name) { 'test_instance' }
  let(:elasticsearch_config) do
    Chef::Resource::ElasticsearchConfig.new(instance_name, run_context)
  end

  before :each do
    @elasticsearchconfig = elasticsearch_config
  end

  describe 'Chef Resource Checks for Chef::Resource::ElasticsearchConfig' do
    it 'Is a Chef::Resource?' do
      assert_kind_of(Chef::Resource, @elasticsearchconfig)
    end

    it 'Is a instance of ElasticsearchConfig' do
      assert_instance_of(Chef::Resource::ElasticsearchConfig,
                         @elasticsearchconfig)
    end
  end

  describe 'Parameter tests for Chef::Resource::ElasticsearchConfig' do
    it "has a 'instance' parameter that can be set" do
      assert_respond_to(@elasticsearchconfig, :instance)
      @elasticsearchconfig.instance('instance_name')
      assert(@elasticsearchconfig.instance, 'instance_name')
    end

    it "has a 'config_type' parameter that can be set" do
      assert_respond_to(@elasticsearchconfig, :config_type)
      @elasticsearchconfig.config_type(:elasticsearch)
      assert(@elasticsearchconfig.config_type, :elasticsearch)
    end

    describe "'config_options' parameter" do
      it 'allows hash like objects' do
        test_config = {
            format: 'plain',
            path: %w(/var/log/httpd/*_log),
            type: 'httpd'
        }
        @elasticsearchconfig.config_options(test_config)
        assert(@elasticsearchconfig.config_options, 'input')
      end

      it 'doesnt allow other types of objects.' do
        assert_raises(Chef::Exceptions::ValidationFailed) do
          @elasticsearchconfig.config_options(%w(foo bar baz))
        end

        assert_raises(Chef::Exceptions::ValidationFailed) do
          @elasticsearchconfig.config_options('foobarbaz')
        end
      end
    end
  end
end
