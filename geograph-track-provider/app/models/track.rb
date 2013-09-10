class Track < ActiveRecord::Base
  attr_accessible :content, :filename, :title, :first_position_latitude, :first_position_longitude
end
