class User < ActiveRecord::Base
  scope :active, lambda { where(active: true) }
  scope :inactive, lambda { where(active: false) }
  
  def to_s
    self.name
  end
end
