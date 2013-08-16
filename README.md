chef-elasticsearch
==================

Simple Resource Provider for elasticsearch instances and configuration.


elasticsearch_instance

  Attributes:

  * `name`
  * `user`
  * `group`
  * `destination_dir`
  * `configuration_dir`
  * `install_options`
  * `service_options`
  * `install_type`
  * `service_type`

currently assumes you will install via the official release zip file.

elasticsearch_plugin

  Attributes:

  * `instance` The instance to associate this plugin with.
  * `plugin` The name of the plugin also the name attribute.
  * `plugin_timeout` Timeout if the installation takes longer than this Fixnum.
  * `install_options` Because we support multiple install methods we support a hash
    of options that may be needed during install.
  * `install_type` We support `manual` and `plugin`. Use plugin for officially supported
    plugins, and manual for other types.`

elasticsearch_config

Examples

Creating a elasticsearch instance in /opt/es/elastic_ops

    elasticsearch_instance 'elastic_ops' do
      destination_dir '/opt/es'
      user 'elastic'
      group 'elastic'
      install_options({
        version: '0.90.2',
        url: 'https://Your-Local-Mirror.example.com/elasticsearch/elasticsearch'
      })
    end


Plugins can be installed two ways. With the `plugin` tool or a `manual` download 
and extract.

Using the elasticsearch `plugin` tool:

    elasticsearch_plugin 'elasticsearch-river-wikipedia' do
      instance 'es_test'
      install_type 'plugin'
      install_options({ version: '1.1.0' })
    end

Using the `manual` method:

    elasticsearch_plugin 'elasticsearch-zookeeper' do
      instance 'es_test'
      install_type 'manual'
      install_options({ version: '0.90.0',
                        url: 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-zookeeper',
                        install_unzip: true,
                        plugin_creates: 'bin/zookeeper'
      })
    end

You can also manage the configuration of a instance. The `config_type`

    elasticsearch_config 'logstash_elasticsearch' do
      instance 'elastic_ops'
      config_type 'elasticsearch'
      config_options # TODO Load from databag.
    end

** Take a look at the [test cookbooks]() for more usage examples.
