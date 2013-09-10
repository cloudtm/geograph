require 'fileutils'

task :update_city => :environment do |t, args|
  puts "Starting..."

  idx_cache = {}

  Track.where('city IS NULL OR city_idx IS NULL').find_each do |track|
    foundcities = 0
    if not track.city
      city = Tag.where('? BETWEEN min_latitude AND max_latitude AND ? BETWEEN min_longitude AND max_longitude',
          track.first_position_latitude, track.first_position_longitude)
      foundcities = city.count
      puts "#{track.first_position_latitude},#{track.first_position_longitude}"
      cities = []
      city.all.each do |c|
        ccent_lat, ccent_lon = (c.min_latitude + c.max_latitude) / 2, (c.min_longitude + c.max_longitude) / 2
        cities << { :name => c.name, :dist => (ccent_lat - track.first_position_latitude) ** 2 + (ccent_lon - track.first_position_longitude) ** 2 }
      end
      cities.sort! { |a, b| a[:dist] <=> b[:dist] }
      if not cities.empty?
        track.city = cities[0][:name]
      end
    end
    if track.city
      if not idx_cache[track.city]
        c = Track.find_by_sql(['SELECT MAX(city_idx) q FROM tracks WHERE city = ?', track.city]).first
        c = c ? c.q : 0
        c = c ? c : 0
      else
        c = idx_cache[track.city]
      end
      track.city_idx = c + 1
      track.save
      puts "#{track.filename} [#{track.title}] [#{track.city} (#{foundcities}) => #{c + 1}]"
      idx_cache[track.city] = c + 1
    else
      track.city = ''
      track.city_idx = 0
      track.save
      puts "#{track.filename} [#{track.title}] [(unknown city)]"
    end
  end

  puts "Finished!"

end

