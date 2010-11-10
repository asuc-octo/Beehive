require 'rubygems'
require 'osx/cocoa'
require 'active_support'

require 'red_artisan/core_image/filters/scale'
require 'red_artisan/core_image/filters/color'
require 'red_artisan/core_image/filters/watermark'
require 'red_artisan/core_image/filters/quality'
require 'red_artisan/core_image/filters/perspective'
require 'red_artisan/core_image/filters/effects'

***REMOVED*** Generic image processor for scaling images based on CoreImage via RubyCocoa.
***REMOVED***
***REMOVED*** Example usage:
***REMOVED***
***REMOVED*** p = Processor.new OSX::CIImage.from(path_to_image)
***REMOVED*** p.resize(640, 480)
***REMOVED*** p.render do |result|
***REMOVED***   result.save('resized.jpg', OSX::NSJPEGFileType)
***REMOVED*** end
***REMOVED***
***REMOVED*** This will resize the image to the given dimensions exactly, if you'd like to ensure that aspect ratio is preserved:
***REMOVED***
***REMOVED*** p = Processor.new OSX::CIImage.from(path_to_image)
***REMOVED*** p.fit(640)
***REMOVED*** p.render do |result|
***REMOVED***   result.save('resized.jpg', OSX::NSJPEGFileType)
***REMOVED*** end
***REMOVED***
***REMOVED*** fit(size) will attempt its best to resize the image so that the longest width/height (depending on image orientation) will match
***REMOVED*** the given size. The second axis will be calculated automatically based on the aspect ratio.
***REMOVED***
***REMOVED*** Scaling is performed by first clamping the image so that its external bounds become infinite, this helps when scaling so that any
***REMOVED*** rounding discrepencies in dimensions don't affect the resultant image. We then perform a Lanczos transform on the image which scales
***REMOVED*** it to the target size. We then crop the image to the traget dimensions.
***REMOVED***
***REMOVED*** If you are generating smaller images such as thumbnails where high quality rendering isn't as important, an additional method is
***REMOVED*** available:
***REMOVED***
***REMOVED*** p = Processor.new OSX::CIImage.from(path_to_image)
***REMOVED*** p.thumbnail(100, 100)
***REMOVED*** p.render do |result|
***REMOVED***   result.save('resized.jpg', OSX::NSJPEGFileType)
***REMOVED*** end
***REMOVED***
***REMOVED*** This will perform a straight affine transform and scale the X and Y boundaries to the requested size. Generally, this will be faster
***REMOVED*** than a lanczos scale transform, but with a scaling quality trade.
***REMOVED***
***REMOVED*** More than welcome to intregrate any patches, improvements - feel free to mail me with ideas.
***REMOVED***
***REMOVED*** Thanks to
***REMOVED*** * Satoshi Nakagawa for working out that OCObjWrapper needs inclusion when aliasing method_missing on existing OSX::* classes.
***REMOVED*** * Vasantha Crabb for general help and inspiration with Cocoa
***REMOVED*** * Ben Schwarz for example image data and collaboration during performance testing
***REMOVED***
***REMOVED*** Copyright (c) Marcus Crafter <crafterm@redartisan.com> released under the MIT license
***REMOVED***
module RedArtisan
  module CoreImage
    class Processor
  
      def initialize(original)
        if original.respond_to? :to_str
          @original = OSX::CIImage.from(original.to_str)
        else
          @original = original
        end
      end
  
      def render(&block)
        raise "unprocessed image: ***REMOVED***{@original}" unless @target
        block.call @target
      end
      
      include Filters::Scale, Filters::Color, Filters::Watermark, Filters::Quality, Filters::Perspective, Filters::Effects
  
      private
  
        def create_core_image_context(width, height)
      		output = OSX::NSBitmapImageRep.alloc.initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel(nil, width, height, 8, 4, true, false, OSX::NSDeviceRGBColorSpace, 0, 0)
      		context = OSX::NSGraphicsContext.graphicsContextWithBitmapImageRep(output)
      		OSX::NSGraphicsContext.setCurrentContext(context)
      		@ci_context = context.CIContext
        end
        
        def vector(x, y, w, h)
          OSX::CIVector.vectorWithX_Y_Z_W(x, y, w, h)
        end
    end
  end
end

module OSX
  class CIImage
    include OCObjWrapper
  
    def method_missing_with_filter_processing(sym, *args, &block)
      f = OSX::CIFilter.filterWithName("CI***REMOVED***{sym.to_s.camelize}")
      return method_missing_without_filter_processing(sym, *args, &block) unless f
    
      f.setDefaults if f.respond_to? :setDefaults
      f.setValue_forKey(self, 'inputImage')
      options = args.last.is_a?(Hash) ? args.last : {}
      options.each { |k, v| f.setValue_forKey(v, k.to_s) }
    
      block.call f.valueForKey('outputImage')
    end
  
    alias_method_chain :method_missing, :filter_processing
      
    def save(target, format = OSX::NSJPEGFileType, properties = nil)
      bitmapRep = OSX::NSBitmapImageRep.alloc.initWithCIImage(self)
      blob = bitmapRep.representationUsingType_properties(format, properties)
      blob.writeToFile_atomically(target, false)
    end
  
    def self.from(filepath)
      raise Errno::ENOENT, "No such file or directory - ***REMOVED***{filepath}" unless File.exists?(filepath)
      OSX::CIImage.imageWithContentsOfURL(OSX::NSURL.fileURLWithPath(filepath))
    end
  end
end

