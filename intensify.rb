require 'sinatra'
require './environments'
require 'mini_magick'
require 'open-uri'
require 'net/http'
require 'securerandom'
require 'pry'

get '/' do
  content_type 'image/gif'

  return "Provide a valid image URL" unless params['url']

  image = MiniMagick::Image.open(params['url'])
  shake = params['shake'] ? [params['shake']&.to_i, 300].min : 3

  # set up paths
  image_path = "tmp/#{image.signature}_#{shake}"
  intensified_path = "tmp/#{image.signature}_#{shake}_intensified.gif"

  # if file already in tmp, return that
  if File.exists?(intensified_path)
    puts "CACHED!"
    return MiniMagick::Image.open(intensified_path).to_blob
  end

  # set up files
  image.resize('300x300>')
  image.write(image_path)
  File.open(intensified_path, "w") {}

  puts "Converting..."

  system("convert -delay 24,1000 -size #{image[:width]}x#{image[:height]} \
      -dispose background \
      -page +#{shake}+#{shake}  #{image_path}   -page -#{shake}+#{shake} #{image_path}  \
      -page -#{shake}-#{shake} #{image_path}   -page +#{shake}-#{shake} #{image_path}  \
      -loop 0 #{intensified_path}")

  MiniMagick::Image.open(intensified_path).to_blob
end
