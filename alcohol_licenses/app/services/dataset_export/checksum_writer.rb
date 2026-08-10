require 'digest'
require 'pathname'

module DatasetExport
  class ChecksumWriter
    def initialize(root:, output_path:)
      @root = Pathname(root)
      @output_path = Pathname(output_path)
    end

    def write
      lines = checksummed_files.map do |path|
        "#{Digest::SHA256.file(path).hexdigest}  #{relative_path(path)}"
      end

      File.write(output_path, "#{lines.join("\n")}\n", encoding: 'UTF-8')
      lines.size
    end

    private

    attr_reader :root, :output_path

    def checksummed_files
      Dir.glob(root.join('**/*'))
        .map { |path| Pathname(path) }
        .select(&:file?)
        .reject { |path| path == output_path }
        .sort
    end

    def relative_path(path)
      path.relative_path_from(root).to_s
    end
  end
end
