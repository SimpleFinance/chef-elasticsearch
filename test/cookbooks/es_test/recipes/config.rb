elasticsearch_instance 'es_test' do
  destination_dir '/opt/es'
  user 'elastic'
  group 'elastic'
  install_options({
    version: '0.90.2',
    url: 'https://download.elasticsearch.org/elasticsearch/elasticsearch'
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
