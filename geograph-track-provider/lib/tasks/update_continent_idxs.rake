require 'fileutils'

task :update_continent_idxs => :environment do |t, args|
#  args.with_defaults(:how_many => 10)
#  if not args[:path]
#    puts "Please provide the source directory as the first argument"
#    exit -1
#  end

  puts "Starting..."

  idx_cache = {}

  Track.where('continent_idx IS NULL').find_each do |track|
    if not idx_cache[track.continent]
      c = Track.find_by_sql(['SELECT MAX(continent_idx) q FROM tracks WHERE continent = ?', track.continent]).first
      c = c ? c.q : 0
      c = c ? c : 0
    else
      c = idx_cache[track.continent]
    end
    track.continent_idx = c + 1
    track.save
    puts "#{track.filename} [#{track.title}] [#{track.continent} => #{c + 1}]"
    idx_cache[track.continent] = c + 1
  end

  puts "Finished!"

end

