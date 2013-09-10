require 'nokogiri'
require 'fileutils'
require 'get_tracks'

class GpxParser < Nokogiri::XML::SAX::Document
  attr_reader :tracks

  def reset
    @tracks = []
    @curtrack = { :name => '(unnamed)', :content => [] }
    @curnode = []
  end

  def initialize
    reset
  end

  def characters chars
    if chars.strip != '' and (@curnode == ['gpx', 'metadata', 'name'] or @curnode == ['gpx', 'trk', 'name'] or @curnode == ['gpx', 'rte', 'name'])
      @curtrack[:name] = chars.strip
    end
  end

  def start_element name, attrs = []
    attrs = Hash[*attrs.flatten]
    @curnode.push(name)
    if name == 'wpt' or name == 'trkpt' or name == 'rtept'
      @curtrack[:content] << [ attrs['lat'], attrs['lon'] ]
    end
  end

  def end_element name
    @curnode.pop
    if (@curnode.empty? and not @curtrack[:content].empty?) or name == 'trk' or name == 'rte'
      @tracks << @curtrack
      @curtrack = { :name => '(unnamed)', :content => [] }
    end
  end
end

task :import_tracks_sax, [:path, :how_many] => :environment do |t, args|
  args.with_defaults(:how_many => 10)
  if not args[:path]
    puts "Please provide the source directory as the first argument"
    exit -1
  end

  puts "Destroying all previously imported tracks"
  Track.destroy_all

  count = 0

  gpxp = GpxParser.new
  parser = Nokogiri::XML::SAX::Parser.new(gpxp)

  puts "Importing new tracks"
  gpxs = Dir.glob(File.join(args.path, '*.gpx'))
  gpxs.each do |gpx|
    print "##{count} [#{gpx}:#{gpxp.tracks.size}] "
    gpxp.reset
    parser.parse_file(gpx)
    sleep(0.5)
    count += 1
    gpxp.tracks.each do |track|
      if not track[:content].empty?
        Track.create({ :title => track[:name], :filename => gpx, :content => track[:content].to_json, 
            :first_position_latitude => track[:content][0][0], :first_position_longitude => track[:content][0][1] })
        sleep(0.1)
        print "#{track[:content].size}."
      else
        print "0."
      end
    end
    puts
  end
end

