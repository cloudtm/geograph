class Countries < ActiveRecord::Base
  attr_accessible :continent, :country, :max_latitude, :max_longitude, :min_latitude, :min_longitude, :name
end
