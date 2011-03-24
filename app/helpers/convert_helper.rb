module ConvertHelper
  
  def get_flv(dir,host,pathparams)
    return nil if dir.blank? || host.blank? || pathparams.blank?
    system("wget -cO public/resources/#{dir}/sample.flv #{host}#{pathparams}")
  end
  
  def convert_to_mp3(dir)
    return nil if dir.blank?
    system("ffmpeg -i public/resources/#{dir}/sample.flv -ar 44100 -ab 160k -ac 2 public/resources/#{dir}/title.mp3;")
  end
  
  def header_data
      '--referer="http://localhost:4000" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/525.13 (KHTML, like Gecko) Chrome/0.A.B.C Safari/525.13"'
  end
  
end
