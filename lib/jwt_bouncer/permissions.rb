# frozen-string-literal: true

require 'jwt'
require 'zlib'

module JwtBouncer
  module Permissions
    def self.compress(permissions)
      stream = StringIO.new
      zip = Zlib::GzipWriter.new(stream)
      begin
        zip.write(permissions.to_json)
      ensure
        zip.close
      end

      Base64.encode64(stream.string)
    end

    def self.decompress(permissions)
      unzipped_stream = StringIO.new
      StringIO.open(Base64.decode64(permissions)) do |stream|
        unzip = Zlib::GzipReader.new(stream)
        begin
          unzipped_stream.write(unzip.read)
        ensure
          unzip.close
        end
      end

      JSON.parse(unzipped_stream.string)
    end

    def self.destructure(permissions)
      destructured_permissions = []
      permissions.each do |service, resources|
        resources.each do |resource, resource_permissions|
          resource_permissions.each do |permission|
            destructured_permissions << [service, resource, permission].join('_')
          end
        end
      end
      destructured_permissions
    end
  end
end
