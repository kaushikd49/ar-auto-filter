module SampleModelDefinitions
  class Order < ActiveRecord::Base
    has_one :product
    has_many :order_items
    has_many :order_item_units, :through => :order_items
  end

  class OrderItem < ActiveRecord::Base
    has_many :order_item_units
  end

  class OrderItemUnit < ActiveRecord::Base
  end

  class Product < ActiveRecord::Base
  end
end