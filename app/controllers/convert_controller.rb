require "net/http"
require "uri"
require "cgi"

class ConvertController < ApplicationController
  
  def welcome
  end
  
  def curlurl
    
    File.delete("sample.flv") if File.exists?("sample.flv")
    File.delete("title.mp3") if File.exists?("title.mp3")
    
    url = params[:url] || nil
    url = "http://www.youtube.com/watch?v=20Ov0cDPZy8" if url.blank?
    url = URI.escape(url)
    
    html = `curl #{url}`
    
    @html = html

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
   
    @html = URI.unescape("#{host}#{pathparams}")
   
    #Download
    `wget -O sample.flv "#{host}#{pathparams}"`
    File.delete("title.mp3") if File.exists?("title.mp3")
    
    #Convert
    `ffmpeg -i sample.flv -ar 44100 -ab 160k -ac 2 title.mp3;`
    FileUtils.move("title.mp3","public/resources/#{title}.mp3")
    
    render :text => "<center><a href='/resources/#{title}.mp3'>Download: #{title}.mp3</a></center>"
    
    
  end
  
end
