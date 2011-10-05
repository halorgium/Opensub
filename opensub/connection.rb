module OpenSub
  class Connection
    def initialize(opts = {})
      @host = opts[:host] || 'http://api.opensubtitles.org/xml-rpc'
      @username = opts[:username] || ''
      @password = opts[:password] || ''
      @language = opts[:language] || 'eng'
      @useragent = opts[:useragent] || 'OS Test User Agent'
      connect
    end

    def first(opts)
      search(opts).first
    end
 
    def search(opts)
      if opts[:filename]
        res = search_by_hash(opts)
      else
        res = search_by_name(opts)
      end
      return [] unless Array === res['data']
      res['data'].map {|s| Subtitle.new(s)}
    end

    def search_by_hash(opts)
      @server.call('SearchSubtitles', @token, [{
        :sublanguageid => opts[:language] || @language,
        :moviehash => Hasher.new.open_subtitles_hash(opts[:filename]),
        :moviebytesize => File.size(opts[:filename])
      }])
    end

    def search_by_name(opts)
      @server.call('SearchSubtitles', @token, [opts])
    end
  
    private
  
    def connect
      @server = XMLRPC::Client.new2(@host)
      res = @server.call('LogIn', @username, @password, @language, @useragent)
      @token = res['token']
    end
  end
end
