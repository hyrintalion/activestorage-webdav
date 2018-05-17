require 'net/dav'
require 'active_support/core_ext/array'

module ActiveStorage
  class Service::WebDAVService < Service

    def initialize(args)
      @path = URI.join(args[:url], args[:path])
      @webdav = Net::DAV.new @path
    end

    def upload(key, io, checksum: nil)
      #Rails.logger.info "метод upload"
      instrument :upload, key: key, checksum: checksum do
        begin
          full_path = path_for key
          @webdav.put(full_path, io, File.size(io))
        rescue StandardError
          raise ActiveStorage::IntegrityError
        end
      end
    end

    def url(key, expires_in:, disposition:, filename:, content_type:)
      #Rails.logger.info "метод url"
      instrument :url, key: key do |payload|
        full_path = path_for key
        payload[:url] = full_path
        full_path
      end
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      #Rails.logger.info "метод url_for_direct_upload"
      instrument :url, key: key do |payload|
        full_path = path_for key
        payload[:url] = full_path
        full_path
      end
    end

    def exist?(key)
      #Rails.logger.info "метод exist?"
      instrument :exist, key: key do |payload|
        answer = @webdav.exists? path_for key
        payload[:exist] = answer
        answer
      end
    end

    def delete(key)
      # Rails.logger.info "метод url"
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
      # Rails.logger.info "метод delete_prefixed"
      instrument :delete_prefixed, prefix: prefix do
        # FIXME это псевдокод, проверить как приходят имена файлов
        options = '<?xml version="1.0"?>
                  <a:propfind xmlns:a="DAV:">
                  <a:prop><a:resourcetype/></a:prop>
                  </a:propfind>'
        files = @webdav.propfind(@path, options)
        files.each do |filename|
          @webdav.delete path_for filename if filename.scan prefix
        end
      end
    end

    def download(key, &block)
      # Rails.logger.info "метод download"
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
      # Rails.logger.info "метод download_chunk"
      instrument :download_chunk, key: key, range: range do
        full_path = path_for key
        @webdav.new(@path).start do |dav|
          dav.get(full_path, 'Range' => "bytes=#{range.begin}-#{range.exclude_end? ? range.end - 1 : range.end}").body
        end
      end
    end

    private

    def path_for(key)
      return key unless @path
      URI.join(@path, key)
    end
  end
end
