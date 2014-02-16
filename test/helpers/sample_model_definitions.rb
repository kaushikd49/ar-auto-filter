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


  def create_tables
    ActiveRecord::Schema.define(:version => 20140124132738) do
      create_table :orders, :force => true do |t|
        t.text :user
        t.string :product_id
        t.integer :quantity, :default => true
      end

      create_table :order_items, :force => true do |t|
        t.string :state
        t.integer :quantity
        t.references :order
      end

      create_table :order_item_units, :force => true do |t|
        t.integer :size, :default => true
        t.references :order_item
      end

      create_table :products, :force => true do |t|
        t.string :vertical
        t.integer :selling_price
        t.references :order
      end
    end
  end

end