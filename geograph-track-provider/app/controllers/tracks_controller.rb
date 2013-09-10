class TracksController < ApplicationController

  def list
    tracktag = params[:tag] || nil
    puts "tracktag = #{tracktag}, length = #{tracktag.length}"
    if not tracktag
      resp = Track.select([:filename, :title]).limit(100)
    else
      if tracktag.length == 2
        tag = Tag.find_by_sql(["SELECT MIN(min_latitude) AS min_latitude, MAX(max_latitude) AS max_latitude, MIN(min_longitude) AS min_longitude, MAX(max_longitude) AS max_longitude FROM tags WHERE country = :country", {:country => tracktag}]).first
      else
        tag = Tag.where('name = ?', tracktag).first
      end
      resp = Track.where('first_position_latitude BETWEEN ? AND ? AND first_position_longitude BETWEEN ? AND ?',
          tag.min_latitude, tag.max_latitude, tag.min_longitude, tag.max_longitude).select(:filename, :title)
    end
    render :json => resp
  end

  def tags
    resp = Tag.select([:name]).limit(100).map{ |m| m.name }
    render :json => resp
  end

  def get
    resp = nil
    if params[:city]
      c = Track.find_by_sql(['SELECT MAX(city_idx) max_idx FROM tracks WHERE city = ?', params[:city]]).first
      if c.max_idx
        resp = Track.where(:city => params[:city], :city_idx => rand(c.max_idx) + 1).first
      end
    elsif params[:citycountry]
      c = Track.find_by_sql(['SELECT MAX(citycountry_idx) max_idx FROM tracks WHERE citycountry = ?', URI.unescape(params[:citycountry])]).first
      if c.max_idx
        resp = Track.where(:citycountry => URI.unescape(params[:citycountry]), :citycountry_idx => rand(c.max_idx) + 1).first
      end
    elsif params[:country]
      c = Track.find_by_sql(['SELECT MAX(country_idx) max_idx FROM tracks WHERE country = ?', params[:country]]).first
      if c.max_idx
        resp = Track.where(:country => params[:country], :country_idx => rand(c.max_idx) + 1).first
      end
    elsif params[:continent]
      c = Track.find_by_sql(['SELECT MAX(continent_idx) max_idx FROM tracks WHERE continent = ?', params[:continent]]).first
      if c.max_idx
        resp = Track.where(:continent => params[:continent], :continent_idx => rand(c.max_idx) + 1).first
      end
    else
      resp = Track.offset(rand(Track.count)).first
    end
    render :json => resp
  end
end
