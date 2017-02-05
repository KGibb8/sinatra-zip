require './lib/entity'
require 'zip'

# The Unzip class unpacks the files and acts as a container for the results.
# Is actually probably unnecessary in the long run.

# The Entity class (needs renaming!) contains the logic that writes the file
# to any specified path and validators to ensure that the file is one of the
# permitted files on the whitelist. In this case, PDF.

# At the moment we can still fake out a PDF file by inputting
# one with "%PDF" at the beginning, %%EOF at the end
# and ".pdf" as the file extension

# Use the HEX_SIGNATURE to guarantee encoding type?

# Must reliably work out how to determine these
# hex = file.unpack("h*")
# encoding = file.encoding.name

# use 'zip' gems module/class Zip::Errors to strip custom Unzip validators out

class Unzip

  attr_reader :file_type, :ext_name, :saved_files, :errors, :tempfile, :discarded_files

  def initialize(file, export_path="./spec/uploads")
    @file = file
    @tempfile = file[:tempfile]
    @errors = []
    @discarded_files = []
    @saved_files = []
    @export_path = export_path

    validate :assess_file_type, :assess_ext_name

    if valid?
      directory = Zip::File.open(@tempfile.path)
      read_files(directory)
    end
  end

  def read_files(directory)
    files = directory.entries
    files.each do |entry|
      next if entry.ftype == :directory
      filename = entry.name.split("/").last
      content = entry.get_input_stream.read
      file = Entity.new(filename, content, @export_path)
      file.valid? ? self.saved_files << file : self.discarded_files << file
    end
  end

  def valid?
    self.errors.empty?
  end

  private

  def validate(*callbacks)
    @validation_callbacks ||= []
    @validation_callbacks += callbacks
    @validation_callbacks.each { |v| self.send(v) }
  end

  def assess_file_type
    begin
      @file_type = IO.popen(["file", "--brief", "--mime-type", @tempfile.path], in: :close, err: :close).read.chomp
      raise UnprocessibleEntity, "File is not a zip" unless @file_type == "application/zip"
    rescue UnprocessibleEntity => e
      self.errors << { message: e }
    end
  end

  def assess_ext_name
    begin
      @ext_name = File.extname(@tempfile.path)
      raise UnprocessibleEntity, "File extension is not .zip" unless @ext_name == ".zip"
    rescue UnprocessibleEntity => e
      self.errors << { message: e }
    end
  end

end
