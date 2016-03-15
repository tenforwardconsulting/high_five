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

    def generate_splash_screen_image(image_path, logo_path, background)
      raise "Requires RMagick gem" unless rmagick?
      image = ChunkyPNG::Image.from_file(image_path)
      width = image.width
      height = image.height
      source = Magick::Image.new(width, height) { self.background_color = background }

      logo = Magick::Image.read(logo_path).first
      scale_factor = min_scale_factor(logo, 0.75*width, 0.3*height)

      logo.scale!(scale_factor)
      source.composite!(logo, Magick::CenterGravity, Magick::AtopCompositeOp)

      source.write(image_path)
    end

    def generate_ios_splash_screen_image(type, ios_path, path, color)
      raise "Requires RMagick gem" unless rmagick?
      case type
      when 'iphone_portrait_8_retina_hd_5_5'
        width = 1242
        height = 2208
      when 'iphone_portrait_8_retina_hd_4_7'
        width = 750
        height = 1334
      when 'iphone_landscape_8_retina_hd_5_5'
        width = 2208
        height = 1242
      when 'iphone_portrait_1x'
        width = 320
        height = 480
      when 'iphone_portrait_2x', 'android'
        width = 640
        height = 960
      when 'iphone_portrait_retina_4'
        width = 640
        height = 1136
      when 'ios-7-iphone_portrait_2x'
        width = 640
        height = 960
      when 'ios-7-iphone_portrait_retina_4'
        width = 640
        height = 1136
      when 'ipad_portrait_1x'
        width = 768
        height = 1024
      when 'ipad_portrait_2x'
        width = 1536
        height = 2048
      when 'ipad_landscape_1x'
        width = 1024
        height = 768
      when 'ipad_landscape_2x'
        width = 2048
        height = 1536
      when 'ipad_portrait_without_status_bar_5_6_1x'
        width = 768
        height = 1004
      when 'ipad_portrait_without_status_bar_5_6_2x'
        width = 1536
        height = 2008
      when 'ipad_landscape_without_status_bar_5_6_1x'
        width = 1024
        height = 748
      when 'ipad_landscape_without_status_bar_5_6_2x'
        width = 2048
        height = 1496
      end

      filename = "#{type}.png"
      splash_path = Dir.glob("#{ios_path}/**/Images.xcassets/LaunchImage.launchimage").first + "/#{filename}"
      puts "Creating #{splash_path}"
      Magick::Image.new(width, height).write(splash_path)
      generate_splash_screen_image splash_path, path, color
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

    def min_scale_factor(image, max_width, max_height)
      width_scale_factor = max_width / image.columns
      height_scale_factor = max_height / image.rows
      sf = [width_scale_factor, height_scale_factor].min
      puts "Warning: upscaling image for splash screen" if sf > 1.0
      sf
    end
  end
end
