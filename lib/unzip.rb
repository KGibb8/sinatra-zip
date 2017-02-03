require 'zip'

# Check its a valid archive first
# Unpack, check each file for:
# 1. Match string to end with ".pdf"
# 2. Match employee information
# If valid, store in memory

class Unzip

  def validate(*callbacks)
    @validation_callbacks ||= []
    @validation_callbacks += callbacks
    @validation_callbacks.each { |v| self.send(v) }
  end

  def initialize(file)
    @file = file
    @tempfile = file[:tempfile]
    @errors = []
    @files = []

    validate :assess_file_type, :assess_ext_name

    if valid?
      folder = Zip::File.open(@tempfile.path)
      read_files(folder)
    end
  end

  def read_files(folder)
    files = folder.entries
    files.each do |entry|
      next if entry.ftype == :directory
      send(:decompressed_file_type, entry)
    end
  end

  def store_file(entry)
    # %%TODO%% Path here is set to test suite. Can we input this or do we set it manually?
    file = File.open("./spec/uploads/#{entry.name.split("/").last}", "w")
    file.write(entry.get_input_stream.read)
    file.close
    @files << file
  end

  def file_type
    @file_type
  end

  def ext_name
    @ext_name
  end

  def files
    @files
  end

  def errors
    @errors
  end

  def valid?
    @errors.empty? ? true : false
  end

  def archive_whitelist
    %w(zip)
  end

  def file_whitelist
    %w(pdf)
  end

  def pdf_signature_matches?(entry)
    entry.header_signature.to_i == 33639248
  end

  def content_type_matches?(entry)
    entry.name.split(".").last == "pdf"
  end

  private

  def assess_file_type
    begin
      @file_type = IO.popen(["file", "--brief", "--mime-type", @tempfile.path], in: :close, err: :close).read.chomp
      raise ValidationError, "File is not a zip" unless @file_type == "application/zip"
    rescue ValidationError => e
      self.errors << { message: e }
    end
  end

  def assess_ext_name
    begin
      @ext_name = File.extname(@tempfile.path)
      raise ValidationError, "File extension is not .zip" unless @ext_name == ".zip"
    rescue ValidationError => e
      self.errors << { message: e }
    end
  end

  def decompressed_file_type(entry)
    begin
      raise UnprocessibleEntity, "Header signature is not pdf" unless pdf_signature_matches? entry
      raise UnprocessibleEntity, "File suffix is not '.pdf'" unless content_type_matches? entry
      store_file(entry)
    rescue UnprocessibleEntity => e
    end
  end

end




      # file_type = IO.open(["file", "--brief", "--mime-type", file.path], in: :close, err: :close).read.chomp
      # raise ValidationError, "File extension is not a pdf" unless file_type == "application/pdf"
      # binding.pry

# module Zip
#   class AnotherEntry

#     def initialize(entry)
#       @entry = entry
#       validates :file_type
#     end

#     def name
#       @entry.name
#     end

#     def extract(arg)
#       @entry.extract(arg)
#     end

#     def get_input_stream
#       @entry.get_input_stream
#     end

#     private

#     def validates(method)
#       self.send(method)
#     end

#     def file_type
#       file_type = @entry.name.split(".").last
#       raise StandardError unless file_type == "zip"
#     end

#   end
# end

# zip = ARGV[0]
# location = ARGV[1]
# raise ArgumentError unless zip && location

# Zip::File.open(zip) do |zfile|
#   zfile.each do |entry|
#     entry = Zip::AnotherEntry.new(entry)
#     puts "Extracting #{entry.name}"
#     entry.extract(File.join(location, entry.name))
#     content = entry.get_input_stream.read
#   end
# end

