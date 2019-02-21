require 'net/dav'
require 'active_support/core_ext/array'

module ActiveStorage
  class Service::WebDAVService < Service

    def initialize(args)
      @path = args[:url]
      return @webdav = args[:net_dav] if args[:net_dav]
      @webdav = Net::DAV.new args[:url]
    end

    def upload(key, io, checksum: nil, **)
      instrument :upload, key: key, checksum: checksum do
        begin
          full_path = path_for key
          answer = @webdav.put(full_path, io, File.size(io))
        rescue StandardError
          raise ActiveStorage::IntegrityError
        end
      end
    end

    def url(key, expires_in:, disposition:, filename:, content_type:)
      instrument :url, key: key do |payload|
        full_path = path_for key
        payload[:url] = full_path
        full_path
      end
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      instrument :url, key: key do |payload|
        full_path = path_for key
        payload[:url] = full_path
        full_path
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        answer = @webdav.exists? path_for key
        payload[:exist] = answer
        answer
      end
    end

    def delete(key)
      instrument :delete, key: key do
        begin
          @webdav.delete path_for key
        rescue StandardError
          # Ignore files already deleted
        end
      end
    end

    # Delete files at keys starting with the +prefix+.
    def delete_prefixed(prefix)
      instrument :delete_prefixed, prefix: prefix do
        files = prefixed_filenames prefix
        files.each do |filename|
          url = path_for filename
          @webdav.delete url
        end
      end
    end

    def download(key, &block)
      full_path = path_for key
      if block_given?
        instrument :streaming_download, key: key do
          @webdav.get(full_path, &block)
        end
      else
        instrument :download, key: key do
          @webdav.get(full_path)
        end
      end
    end

    def download_chunk(key, range)
      instrument :download_chunk, key: key, range: range do
        range_end = range.exclude_end? ? range.end - 1 : range.end
        range_for_dav = "bytes=#{range.begin}-#{range_end}"

        full_path = path_for key
        @webdav.get(full_path, 'Range' => range_for_dav)
      end
    end

    private

    def prefixed_filenames(prefix)
      options = <<XML
          <?xml version="1.0"?>
            <a:propfind xmlns:a="DAV:">
              <a:prop><a:resourcetype/></a:prop>
          </a:propfind>
XML
      answer = @webdav.propfind(@path, options)

      answer.xpath('//D:href').select do |href|
        href = href.to_s.sub('<D:href>', '').sub('</D:href>', '').split('/').last
        href if href.scan(prefix).size > 0
      end
    end

    def path_for(key)
      return key unless @path
      URI.join(@path, key)
    end
  end
end
