class Cart
  include ProductExtension
  include ActiveModel::API
  attr_accessor :quantity, :product

  validates :product, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  class << self
    def take_all(session_products)
      Product.where(id: session_products.keys)
             .map do |product|
        new(product:,
            quantity: session_products[product.id.to_s].to_i)
      end
    end

    def total_quantity(session_products)
      session_products.values.sum
    end

    def create(session_products)
      new(product: Product.find(session_products[:product_id]), quantity: session_products[:quantity].to_i)
    end
  end

  def save(session_products)
    return false unless valid?

    session_products[product.id.to_s] = quantity
    true
  end
end
