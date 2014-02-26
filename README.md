# Activerecord::AutoFilter

Configuration based condition building and inclusion handling extension for ActiveRecord::Base

In case of eager loading of a model and its associations, it may be required to obtain query results based on filter
criteria that spans across multiple associations. To achieve this, we tend to construct dynamic where clauses
based on the presence of corresponding filter criteria.
Although, the effort in doing this is less, it causes code duplication and hence violates the DRY principle. This
gem tries to address that concern. Given request param hash and query specification hash, it is capable of emitting the
required associations that need to be included and the where conditions that need to applied on a given model, to
achieve the desired result or even apply them to the model directly.

The primary goal of this gem is building dynamic query conditions. So, it is not limited to catering to the needs of
eager loading like above and it can also be used to build dynamic where conditions on just a given model too.

Notes: The following concerns will be addressed later.
- Currently it is mysql specific as the condition extraction is based on splitting the arel query by the word 'WHERE'.
- Instead of only building where conditions based on param value presence, accept procs for providing better control for the programmer.


## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-auto_filter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-auto_filter

## Usage

Please see demo.rb for usage. To execute the demo, do the following:
1. Checkout this repo
2. Run bundle install
3. Run ruby demo.rb

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
