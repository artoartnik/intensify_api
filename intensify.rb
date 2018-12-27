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

  # set up paths
  image_path = "tmp/#{image.path.split("/").last}"
  intensified_path = "tmp/#{SecureRandom.hex(8)}.gif"

  # set up files
  image.write(image_path)
  File.open(intensified_path, "w") {}

  shake = params['shake']&.to_i || 5

  puts "Converting..."

  system("convert -delay 24,1000 -size #{image[:width]}x#{image[:height]} \
      -dispose background \
      -page +#{shake}+#{shake}  #{image_path}   -page -#{shake}+#{shake} #{image_path}  \
      -page -#{shake}-#{shake} #{image_path}   -page +#{shake}-#{shake} #{image_path}  \
      -loop 0 #{intensified_path}")

  MiniMagick::Image.open(intensified_path).to_blob
end
