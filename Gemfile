source 'https://rubygems.org'

# Specify your gem's dependencies in blah.gemspec
gemspec

# Database Adapters
platforms :ruby do
  gem "mysql2"
end

platforms :jruby do
  gem "jdbc-mysql"
  gem "activerecord-jdbcmysql-adapter"
end



group :test do
  gem 'test-unit'
  gem "shoulda", '3.0.1'
  gem "shoulda-context", '1.0.0'
  gem "shoulda-matchers", '1.0.0'
end

