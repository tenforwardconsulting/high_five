module HighFive
  module ImageHelper

    # replace the image at image_path with a resized version of the image at source_path
    def replace_image(image_path, source_path)
      image = ChunkyPNG::Image.from_file(image_path)

      if (rmagick?)
        source = Magick::Image.read(source_path).first
        resized = source.scale(image.height, image.width)
        resized.write(image_path)
      else
        source = ChunkyPNG::Image.from_file(source_path)
        source.resize(image.height, image.width).save(image_path)
      end

    end

    private

    def rmagick?
      @rmagick ||= begin
        require 'RMagick'
        puts "Using RMagick..."
        true
      rescue LoadError
        puts "Using ChunkyPNG..."
        false
      end
    end
  end
end
