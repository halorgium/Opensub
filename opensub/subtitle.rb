require 'open-uri'
require 'zlib'

module OpenSub
  class Subtitle
    attr_reader :opts

    def initialize(opts)
      @opts = opts
    end

    def save(opts)
      if opts[:video_filename]
        unless fname = subtitles_filename(opts[:video_filename])
          raise "Failed to generate subtitles filename for '#{opts[:video_filename]}'"
        end
      else
        unless fname = opts[:filename]
          raise "No :filename or :video_filename option was passed"
        end
      end
      fname << ".#{@opts['IDSubtitleFile']}" if opts[:include_suffix]
      File.open(fname, 'w') {|f| f.write download}
      fname
    end

    def download
      data = open(@opts['SubDownloadLink'])
      Zlib::GzipReader.new(data).read
    end

    private

    def subtitles_filename(video_name)
      bname = File.basename(video_name)
      return unless bname =~ /^(.+)\.(.+)$/
      File.join(File.dirname(video_name), "#{$1}.srt")
    end
  end
end
