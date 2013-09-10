require 'fileutils'

task :update_citycountry => :environment do |t, args|
  puts "Starting..."

  idx_cache = {}
  n = 0

  Track.where('citycountry IS NULL OR citycountry_idx IS NULL').find_each do |track|
    foundcities = 0
    if not track.citycountry
      city = Tag.where('? BETWEEN min_latitude AND max_latitude AND ? BETWEEN min_longitude AND max_longitude',
          track.first_position_latitude, track.first_position_longitude)
      foundcities = city.count
      cities = []
      city.all.each do |c|
        ccent_lat, ccent_lon = (c.min_latitude + c.max_latitude) / 2, (c.min_longitude + c.max_longitude) / 2
        cities << { :name => c.name, :country => c.country, 
            :dist => (ccent_lat - track.first_position_latitude) ** 2 + (ccent_lon - track.first_position_longitude) ** 2 }
      end
      cities.sort! { |a, b| a[:dist] <=> b[:dist] }
      if not cities.empty?
        track.citycountry = cities[0][:name] + ' (' + cities[0][:country] + ')'
      end
    end
    if track.citycountry
      if not idx_cache[track.citycountry]
        c = Track.find_by_sql(['SELECT MAX(citycountry_idx) q FROM tracks WHERE city = ? AND country = ?', track.city, track.country]).first
        c = c ? c.q : 0
        c = c ? c : 0
      else
        c = idx_cache[track.citycountry]
      end
      track.citycountry_idx = c + 1
      track.save
      puts "[#{n}] #{track.filename} [#{track.title}] [#{track.citycountry} (#{foundcities}) => #{c + 1}]"
      n = n + 1
      idx_cache[track.citycountry] = c + 1
    else
      track.citycountry = ''
      track.citycountry_idx = 0
      track.save
      puts "[#{n}] #{track.filename} [#{track.title}] [(unknown city)]"
      n = n + 1
    end
  end

  puts "Finished!"

end

