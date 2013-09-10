  desc "Load all gpx routes stored in tmp/gpxs folder."
  task :classify_gpxs => :environment do
    gpxs = Dir.glob(File.join(Rails.root, 'vendor', 'gpxs', 'us', '*.gpx'))
    gpxs.each do |gpx|
      route = nil
      puts "### FILE #{gpx}"
      file = File.open(gpx)
      doc = Nokogiri::XML(file)
      rtes = doc.css("rte")
      trks = doc.css("trk")
      wpts = doc.css("wpt")
      if !rtes.blank?
        rtes.each do |rte|
          route_name = rte.css("name").first.inner_text.capitalize
          route = []
          rte.css("rtept").each_with_index do |rtept, index|
            route << {
              :latitude => rtept['lat'],
              :longitude => rtept['lon'],
              :progressive => index
            }
          end
          puts_route route_name, route
        end
      elsif !trks.blank?
        trks.each do |trk|
          route_name = trk.css("name").first.inner_text.capitalize
          route = []
          trk.css("trkpt").each_with_index do |trkpt, index|
            route << {
              :latitude => trkpt['lat'],
              :longitude => trkpt['lon'],
              :progressive => index
            }
          end
          puts_route route_name, route
        end

      elsif !wpts.blank?
        route_name = doc.css("metadata").css("name").first.inner_text.capitalize
        route = []
        wpts.each_with_index do |wpt, index|
          route << {
            :latitude => wpt['lat'],
            :longitude => wpt['lon'],
            :progressive => index
          }
        end
        puts_route route_name, route
      end

      file.close
    end
  end

  private

  def puts_route(route_name, route)
    classes = classify(route[0][:latitude], route[0][:longitude])
    puts "Route #{route_name} with #{route.size} positions, first #{route[0][:latitude]},#{route[0][:longitude]}, classes: #{classes}"
  end

  def classify(lat, lon)
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
