require 'mini_magick'

module Yavolo
  class ImageProcessing
    class << self
      def image_dimensions_valid?(file_path:, width:, height:)
        image = MiniMagick::Image.open(file_path)
        image[:width] >= width && image[:height] >= height
      end
    end

  end
end
