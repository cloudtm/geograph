require 'fileutils'

task :update_country_idxs => :environment do |t, args|
#  args.with_defaults(:how_many => 10)
#  if not args[:path]
#    puts "Please provide the source directory as the first argument"
#    exit -1
#  end

  puts "Starting..."

  idx_cache = {}

  Track.where('country_idx IS NULL').find_each do |track|
    if not idx_cache[track.country]
      c = Track.find_by_sql(['SELECT MAX(country_idx) q FROM tracks WHERE country = ?', track.country]).first
      c = c ? c.q : 0
      c = c ? c : 0
    else
      c = idx_cache[track.country]
    end
    track.country_idx = c + 1
    track.save
    puts "#{track.filename} [#{track.title}] [#{track.country} => #{c + 1}]"
    idx_cache[track.country] = c + 1
  end

  puts "Finished!"

end

