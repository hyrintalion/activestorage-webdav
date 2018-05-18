require 'net/dav'
require 'active_support/core_ext/array'

module ActiveStorage
  class Service::WebDAVService < Service

    def initialize(args)
      @path = args[:url]
      @webdav = Net::DAV.new args[:url]
    end

    def upload(key, io, checksum: nil)
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
          @webdav.delete path_for filename
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
        full_path = path_for key
        range_for_dav = "bytes=#{range.begin}-#{range.exclude_end? ? range.end - 1 : range.end}"

        @webdav.get(full_path, 'Range' => range_for_dav)
      end
    end


    def prefixed_filenames(prefix)
      # FIXME это псевдокод, проверить как приходят имена файлов
      answer = @webdav.propfind(@path, '<?xml version="1.0"?>
                  <a:propfind xmlns:a="DAV:">
                  <a:prop><a:resourcetype/></a:prop>
                  </a:propfind>')
      # распарсить XML
      doc = Nokogiri::XML(answer)
      #answer = files.find_all{ |filename| filename.scan prefix }
    end

    private
    def path_for(key)
      return key unless @path
      URI.join(@path, key)
    end
  end
end
