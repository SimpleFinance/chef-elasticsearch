source 'https://rubygems.org'

group :test do
  gem 'chef', '>= 11.4.4'
  gem 'minitest'
  gem 'flog'
  gem 'rake'
  gem 'reek', '>= 1.3.1'
  gem 'rubocop'
  gem 'yard'
  gem 'coveralls', require: false
end

group :integration do
  gem 'test-kitchen',
      git: 'git://github.com/opscode/test-kitchen.git',
      branch: 'master'
  gem 'busser'
  gem 'busser-minitest'
  gem 'kitchen-vagrant'
  gem 'berkshelf', '>= 2.0.7'
end
