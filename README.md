# Activerecord::AutoFilter

Configuration based condition building and inclusion handling extension for ActiveRecord::Base

In case of eager loading of a model and its associations, it may be required to obtain query results based on filter criteria that span across multiple associations. To achieve this, we tend to construct dynamic where clauses based on the presence of certain filter criteria. Since this happens so frequently, it causes code duplication and hence violates the DRY principle. This gem tries to address that concern. Given request param hash and query specification hash, it is capable of emitting the required associations that need to be included, and where conditions that need to applied on a given model, to achieve the desired result or even apply them to the model directly.

**The primary goal of this gem is to build dynamic query conditions**. It is not limited to catering to the needs of
eager loading like above and can also be used to build where conditions on just a model too. All that is required is 
- request-params 
- query-specification
- proper association definitions(if needed).




**Notes:** 

1. See activerecord-auto_filter.gemspec for allowed ruby versions.

2. Following issues will be addressed later

- Currently it is mysql specific as the condition extraction is based on splitting the Arel::Table query by the word 'WHERE'.
- Accept Procs for determining the condition for building where clause, instead of just param value presence. This gives better control for the programmer.


## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-auto_filter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-auto_filter

## Demo

Run demo.rb for usage demo. Steps are below.

1. Checkout this repo
2. Run bundle install
3. Run ruby demo.rb

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
