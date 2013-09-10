require 'nokogiri'
require 'fileutils'
require 'get_tracks'

task :import_tracks, [:path, :how_many] => :environment do |t, args|
  args.with_defaults(:how_many => 10)
  if not args[:path]
    puts "Please provide the source directory as the first argument"
    exit -1
  end

  puts "Destroying all previously imported tracks"
  Track.destroy_all

  count = 0

  puts "Importing new tracks"
  gpxs = Dir.glob(File.join(args.path, '*.gpx'))
  gpxs.each do |gpx|
    doc = Nokogiri::XML(File.open(gpx))
    sleep(0.5)
    tracks = GetTracks.get_tracks doc
    print "[#{gpx}:#{tracks.size}] "
    tracks.each do |track|
      if not track[:content].empty?
        Track.create({ :title => track[:name], :filename => gpx, :content => track[:content].to_json, 
            :first_position_latitude => track[:content][0][:latitude], :first_position_longitude => track[:content][0][:longitude] })
        sleep(0.1)
        print "."
      else
        print "o"
      end
    end
    puts
  end
end

def compute_classes(route)
  if route and route[0]
    classes = GpxClassifier.classify(route[0][:latitude], route[0][:longitude])
  else
    classes = []
  end
  classes
end

class GpxClassifier
  def self.classify(lat, lon)
    lat = lat.to_f
    lon = lon.to_f
    classes = []
    if lat >= 35.639441 and lat <= 58.493694 and lon >= -11.337891 and lon <= 30.014648
      classes << "Europe"
    end 
    if lat >= 36.597889 and lat <= 46.739861 and lon >= 6.547852 and lon <= 18.852539
      classes << "Italy"
    end 
    if lat >= 41.182788 and lat <= 42.811522 and lon >= 11.612549 and lon <= 13.826294  
      classes << "Lazio"
    end 
    if lat >= 41.798959 and lat <= 41.987057 and lon >= 12.369232 and lon <= 12.623291
      classes << "Rome"
    end 
    classes
  end
end

