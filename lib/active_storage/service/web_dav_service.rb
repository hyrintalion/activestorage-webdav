require 'net/webdav/client'

module ActiveStorage
  class Service::WebDAVService < Service

    def initialize(args)
      puts args
      @path = args[:url]
      @webdav_client = Net::Webdav::Client.new args[:url]
    end

    def upload(key, io, checksum: nil)
      instrument :upload, key: key, checksum: checksum do
        begin
          full_path = path_for key
          @webdav_client.put_file(full_path, io, true)
        rescue StandardError
          raise ActiveStorage::IntegrityError
        end
      end
    end

    def url(key, expires_in:, disposition:, filename:, content_type:)
      instrument :url, key: key do |payload|
        generated_url = path_for key
        payload[:url] = generated_url
        generated_url
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        full_path = path_for key
        answer = @webdav_client.file_exists? full_path
        payload[:exist] = answer
        answer
      end
    end

    def delete(key)
      instrument :delete, key: key do
        begin
          full_path = path_for key
          @webdav_client.delete_file full_path
        rescue StandardError
          # Ignore files already deleted
        end
      end
    end

    # Return the content of the file at the +key+.
    def download(key)
      # get_file remote_file_path, local_file_path
      raise NotImplementedError
    end

    # Return the partial content in the byte +range+ of the file at the +key+.
    def download_chunk(key, range)
      raise NotImplementedError
    end

    # Delete files at keys starting with the +prefix+.
    def delete_prefixed(prefix)
      raise NotImplementedError
    end

    # Returns a signed, temporary URL that a direct upload file can be PUT to on the +key+.
    # The URL will be valid for the amount of seconds specified in +expires_in+.
    # You must also provide the +content_type+, +content_length+, and +checksum+ of the file
    # that will be uploaded. All these attributes will be validated by the service upon upload.
    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      raise NotImplementedError
    end

    private

    def path_for(key)
      return key unless @path
      File.join(@path, key)
    end
  end
end
