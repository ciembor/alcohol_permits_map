require 'fileutils'
require 'json'

module DatasetExport
  class JsonWriter
    def self.write(path, payload)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "#{JSON.pretty_generate(payload)}\n", encoding: 'UTF-8')
    end
  end
end

