require 'net/dav'

module ActiveStorage
  class Service::WebDAVService < Service

    def initialize(args)
      puts args
      @path = args[:url]
      @webdav = Net::DAV.new args[:url]
    end

    def upload(key, io, checksum: nil)
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
      instrument :url, key: key do |payload|
        generated_url = path_for key
        payload[:url] = generated_url
        generated_url
      end
    end

    # Returns a signed, temporary URL that a direct upload file can be PUT to on the +key+.
    # The URL will be valid for the amount of seconds specified in +expires_in+.
    # You must also provide the +content_type+, +content_length+, and +checksum+ of the file
    # that will be uploaded. All these attributes will be validated by the service upon upload.
    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      instrument :url, key: key do |payload|
        generated_url = path_for key
        payload[:url] = generated_url

        generated_url
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        full_path = path_for key
        answer = @webdav.exists? full_path
        payload[:exist] = answer
        answer
      end
    end

    def delete(key)
      instrument :delete, key: key do
        begin
          full_path = path_for key
          @webdav.delete full_path
        rescue StandardError
          # Ignore files already deleted
        end
      end
    end

    # Delete files at keys starting with the +prefix+.
    def delete_prefixed(prefix)
      instrument :delete_prefixed, prefix: prefix do
        # получить список файлов
        curl
        # проверить имена на префикс
        # удалить
        #Dir.glob(path_for("#{prefix}*")).each do |path|

        #  full_path = path_for key
        #  @webdav.delete full_path
        #end
      end
    end

    # Return the content of the file at the +key+.
    def download(key)
      # get(path, &block) ⇒ Object
      # Получить содержимое ресурса в виде строки
      # Если вызывается с блоком, каждый фрагмент тела объекта возвращает его в виде строки,
      # поскольку он считывается из сокета. Обратите внимание, что в этом случае возвращаемый
      # объект ответа не будет содержать (значимого) тела.

      #if block_given?
      #  instrument :streaming_download, key: key do
      #    stream(key, &block)
      #  end
      #else
      #  instrument :download, key: key do
      #    _, io = blobs.get_blob(container, key)
      #    io.force_encoding(Encoding::BINARY)
      #  end
      #end
    end

    # Return the partial content in the byte +range+ of the file at the +key+.
    def download_chunk(key, range)
      raise NotImplementedError
    end



    private

    def path_for(key)
      return key unless @path
      File.join(@path, key)
    end
  end
end
