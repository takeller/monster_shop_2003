class Item <ApplicationRecord
  belongs_to :merchant
  has_many :reviews, dependent: :destroy
  has_many :item_orders
  has_many :orders, through: :item_orders

  validates_presence_of :name,
                        :description,
                        :price,
                        :image,
                        :inventory
  validates_inclusion_of :active?, :in => [true, false]
  validates_numericality_of :price, greater_than: 0


  def average_review
    reviews.average(:rating)
  end

  def sorted_reviews(limit, order)
    reviews.order(rating: order).limit(limit)
  end

  def no_orders?
    item_orders.empty?
  end

  def modify_inventory(type_and_quantity)
    if type_and_quantity[:type] == :increase
      final_amount = self.inventory + type_and_quantity[:quantity]
    elsif type_and_quantity[:type] == :decrease
      final_amount = self.inventory - type_and_quantity[:quantity]
    end
    update(inventory: final_amount)
  end

  def self.sorted_items(limit, order)
    joins(:item_orders).select("items.*, sum(quantity) as total_bought").group(:id).order("sum(quantity) #{order}").limit(limit)
  end
end
