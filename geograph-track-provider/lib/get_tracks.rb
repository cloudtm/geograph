require 'nokogiri'
require 'fileutils'

class GetTracks
  def self.get_tracks(doc)
    tracks = []
    rtes = doc.css("rte")
    trks = doc.css("trk")
    wpts = doc.css("wpt")
    if !rtes.empty?
      rtes.each do |rte|
        track_name = rte.css("name").first.inner_text.capitalize
        track_content = []
        rte.css("rtept").each_with_index do |rtept, index|
          track_content << {
            :latitude => rtept['lat'],
            :longitude => rtept['lon'],
            :progressive => index
          }
        end
        tracks << { :name => track_name, :content => track_content }
      end
    elsif !trks.empty?
      trks.each do |trk|
        track_name = trk.css("name").first ? trk.css("name").first.inner_text.capitalize : '(unknown name)'
        track_content = []
        trk.css("trkpt").each_with_index do |trkpt, index|
          track_content << {
            :latitude => trkpt['lat'],
            :longitude => trkpt['lon'],
            :progressive => index
          }
        end
        tracks << { :name => track_name, :content => track_content }
      end
    elsif !wpts.empty?
      track_name = doc.css("metadata").css("name").first.inner_text.capitalize
      track_content = []
      wpts.each_with_index do |wpt, index|
        track_content << {
          :latitude => wpt['lat'],
          :longitude => wpt['lon'],
          :progressive => index
        }
      end
      tracks << { :name => track_name, :content => track_content }
    end
    tracks
  end
end
