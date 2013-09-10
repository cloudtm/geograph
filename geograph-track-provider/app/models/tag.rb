class Tag < ActiveRecord::Base
  attr_accessible :max_latitude, :max_longitude, :min_latitude, :min_longitude, :name
end
