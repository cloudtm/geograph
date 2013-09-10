require 'rubygems'
require 'mechanize'
require 'net/http'

agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
  agent.redirect_ok = :all
  agent.follow_meta_refresh = true
  agent.user_agent = "my user agent"
  agent.keep_alive = false
  agent.open_timeout = 20
  agent.read_timeout = 20
  agent.robots = false
  agent.max_file_buffer = 100000000000000
  agent.pluggable_parser.default = Mechanize::Download

}

OSM_URL = "http://www.openstreetmap.org/"
NUM_PAGES = 36645
#for each page of traces
1.upto(NUM_PAGES) do |p|

  puts "==================== PAGE #{p} ======================="


  #get links from main page
  download_pages_links = []
  agent.get(OSM_URL+"traces/page/#{p}") do |page|
    download_pages_links = page.links_with(:text => /(.*)\.gpx/i)
  end

  #go to the download page and download file links
  #and download files
  download_pages_links.each do |l|
    #puts "***************************************"
    puts l.text
    #go to the download page
    agent.get(l.href) do |page|
      #find the download link
      download_link = page.link_with(:text => /(s*)download(s*)/i)
     # puts "downloading #{OSM_URL+download_link.href}"
      download_url = OSM_URL+download_link.href
      download_url.gsub!("//","/")
      download_url.gsub!("http:/","http://") #HACK
      begin
      agent.get(download_url).save(l.text)
     rescue Exception => ex
       puts "WARNING: could not download #{download_url}"
      puts ex.message
      puts ex.inspect
      # retry
     end

    end
  end
end




