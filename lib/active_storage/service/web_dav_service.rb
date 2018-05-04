require 'net/webdav/client'

module ActiveStorage
  class Service::WebDAVService < Service

    def initialize(args)
      @webdav_client = Net::Webdav::Client.new args[:url]
      @path = args[:url]
    end

    def upload(key, io, checksum: nil)
      instrument :upload, key: key, checksum: checksum do
        begin
          full_path = "#{@path}#{key}#{File.extname(io)}"
          @webdav_client.put_file(full_path, io)
        rescue StandardError
          raise ActiveStorage::IntegrityError
        end
      end
    end

    def url(key, expires_in:, disposition:, filename:, content_type:)
      instrument :url, key: key do |payload|
        ext = filename.to_s.split('.').last
        generated_url = "#{@path}#{key}.#{ext}"
        payload[:url] = generated_url
        generated_url
      end
    end

  end
end
