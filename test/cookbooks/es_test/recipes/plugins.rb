package 'openjdk-7-jre-headless'

elasticsearch_instance 'es_test' do
  destination_dir '/opt/es'
  user 'elastic'
  group 'elastic'
  install_options({
    version: '0.90.2',
    url: 'https://download.elasticsearch.org/elasticsearch/elasticsearch'
  })
end

elasticsearch_plugin 'elasticsearch-jetty' do
  instance 'es_test'
  install_options({ version: '0.90.0' })
end

elasticsearch_plugin 'elasticsearch-zookeeper' do
  instance 'es_test'
  install_options({ version: '0.90.0',
                    url: 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty',
                    install_method: 'manual',
                    plugin_creates: 'bin/zookeeper'
  })
end


elasticsearch_config 'es_test_config' do
  instance 'es_test'
  config_type 'elasticsearch'
  config_options({
    node: {
      name: node.fqdn,
      data: true,
      master: true
    },
    index: {
      number_of_shards: 5,
      number_of_replicas: 1
    }
  })
end

elasticsearch_config 'es_test_logs' do
  instance 'es_test'
  config_type 'logging'
  config_options({
    rootLogger: 'INFO, file',
    logger: {
      action: 'DEBUG',
      },
    appender:{
      file: {
        type: 'dailyRollingFile',
        file: '${path.logs}/${cluster.name}.log',
        datePattern: "'.'yyyy-MM-dd",
        layout: {
          type: 'pattern',
          conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"
        }
      }
    }
  })
end
