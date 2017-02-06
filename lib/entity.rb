class Entity

  PDF_HEX_SIGNATURE = "25504446"
  PDF_HEX_TRAILERS = ["0A2525454F46", "0A2525454F460A", "0D0A2525454F460D0A", "0D2525454F460D"]
  PDF_ISO_8859_1_HEADER = "%PDF"
  PDF_ASCII_TRAILERS = ["\n%%EOF", "\n%%EOF\n", "\n\n%%EOF\n\n", "\n%%EOF\n"]

  attr_reader :errors, :name, :content, :file_type, :extension

  def initialize(name, content, path)
    @name = name
    @content = content
    @path = path
    @extension = name.split(".").last
    @errors = []

    validate :hex_header_signature, :hex_trailer_signature, :iso_signature, :ascii_signature, :file_extension

    store_file if valid?
  end

  def valid?
    self.errors.empty?
  end

  def file_whitelist
    %w(pdf PDF)
  end

  private

  def validate(*callbacks)
    @validation_callbacks ||= []
    @validation_callbacks += callbacks
    @validation_callbacks.each { |v| self.send(v) }
  end

  def store_file
    binding.pry
    file = File.open("#{@path}/#{@name}", "w")
    file.write(@content)
    file.close
  end

  def iso_signature
    begin
      raise UnprocessibleEntity, "ISO-8859-1 header signature not compatible" unless @content.to_s[0..3] == PDF_ISO_8859_1_HEADER
    rescue UnprocessibleEntity => e
      self.errors << { message: e.message }
    end
  end

  def hex_header_signature
    begin
      header = @content.to_s[0..3]
      sig = header.scan(/./).map{ |l| l.unpack('h*') }
      signature = sig.map{ |s| s.first.reverse }.join
      raise UnprocessibleEntity, "Hex signature not compatible" unless signature == PDF_HEX_SIGNATURE
    rescue UnprocessibleEntity => e
      self.errors << { message: e.message }
    end
  end

  def hex_trailer_signature
    begin
      trailer = @content.to_s[-9..-1]
      sig = []
      trailer.each_char{ |c| sig << c }
      signature = sig.map{ |c| c.unpack('h*') }.map{ |s| s.first.reverse }.join.upcase
      raise UnprocessibleEntity, "Hex trailer not compatible" unless PDF_HEX_TRAILERS.select{ |t| signature.match(t) }.any?
    rescue UnprocessibleEntity => e
      self.errors << { message: e.message }
    end
  end

  def ascii_signature
    begin
      raise UnprocessibleEntity, "ASCII signature not compatible" unless PDF_ASCII_TRAILERS.select{ |t| @content.to_s.chomp[-9..-1].match(t) }.any?
    rescue UnprocessibleEntity => e
      self.errors << { message: e.message }
    end
  end

  def file_extension
    begin
      raise UnprocessibleEntity, "File extension not whitelisted" unless file_whitelist.select{|wl| wl == @extension }.any?
    rescue UnprocessibleEntity => e
      self.errors << { message: e.message }
    end
  end

end

