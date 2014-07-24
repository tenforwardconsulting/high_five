module HighFive
  module ImageHelper

    # replace the image at path `image` with a resized version of the image at `source`
    def replace_image(image_path, source_path)
      image = ChunkyPNG::Image.from_file(image_path)

      if (rmagick?)
        source = Magick::Image.read(source_path).first
        resized = source.scale(image.height, image.width)
        resized.write(image_path)
      else
        source = ChunkyPNG::Image.from_file(path)
        source.resize(image.height, image.width).save(image_path)
      end

    end

    private
    def rmagick?
      @rmagick ||= begin
        require "rmagick"
        puts "Using rmagick..."
        true
      rescue LoadError
        puts "using ChunkyPNG..."
        false
      end
    end
  end
end