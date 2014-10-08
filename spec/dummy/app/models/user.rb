class User < ActiveRecord::Base
  # attr_accessible :title, :body
  
  def to_s
    self.name
  end
end
