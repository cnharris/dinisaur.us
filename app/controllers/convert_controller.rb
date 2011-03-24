require "net/http"
require "uri"
require "cgi"
require "digest/sha1"

class ConvertController < ApplicationController
  
  include ConvertHelper
  
  def welcome
  end
  
  def convert
    
    url = params[:url] || nil
    
    if(url.blank? || !url.match(/^http:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=\w+)(?:\S+)?$/i))
      render :json => { :msg => "Your url is not valid" }
      return
    end
    
    url = URI.escape(url)
    html = `curl #{url}`
    #grab title and sanitize
    title = html.scan(/\<title\>[^\>]+/i)[0].gsub(/<[^\>]+>/i,"").gsub(/YouTube[^\-]+\-/i,"").gsub(/\<\/title/,"").gsub(/\\n/,"").strip
    title = CGI.unescapeHTML(title)
    
    #grab correct url
    geturls = html.scan(/fmt_url_map\=[0-9]{2}\%7C[^;]+/i)[0]
    geturls = geturls.split(/\%7C/).last
    vidurl = URI.unescape(geturls)
    vidurl = vidurl.split(/videoplayback\?/)
    host = "#{vidurl[0]}"
    pathparams = "videoplayback?#{vidurl[1]}"
    
    p "VIDEO URL: #{host}#{pathparams}"
    
    #make unique directory
    dir = Digest::SHA1.hexdigest "#{Time.now.usec}#{request.remote_ip}"
    Dir.mkdir("public/resources/#{dir}")
    
    IO.popen("wget -cO public/resources/#{dir}/sample.flv #{host}#{pathparams} --no-cookies #{header_data}") do |pipe| 
      pipe.read
    end
    
    #system("wget -cO public/resources/#{dir}/sample.flv #{host}#{pathparams}")
    
    render :json => { :msg => "<center><div style='margin:10px auto;'>Download: <a href='public/resources/#{dir}/#{title}.mp3'>#{title}.mp3</a></div></center>" }
    return
    
  end
  
end
