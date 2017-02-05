class Entity

  PDF_HEX_SIGNATURE = "25 50 44 46"
  PDF_ISO_8859_1 = "%PDF"
  PDF_ASCII_SIGNATURE = "%%EOF"

  attr_reader :errors, :name, :content, :file_type, :extension

  def initialize(name, content, path)
    @name = name
    @content = content
    @path = path
    @extension = name.split(".").last
    @errors = []

    validate :iso_signature, :ascii_signature, :file_extension
    store_file if valid?
  end

  def valid?
    self.errors.empty?
  end

  def file_whitelist
    %w(pdf)
  end

  private

  def validate(*callbacks)
    @validation_callbacks ||= []
    @validation_callbacks += callbacks
    @validation_callbacks.each { |v| self.send(v) }
  end

  def store_file
    file = File.open("#{@path}/#{@name}", "w")
    file.write(@content)
    file.close
  end

  def iso_signature
    begin
      raise UnprocessibleEntity, "ISO-8859-1 signature not compatible" unless @content.to_s[0..3] == PDF_ISO_8859_1
    rescue UnprocessibleEntity => e
      self.errors << { message: e.message }
    end
  end

  def ascii_signature
    begin
      raise UnprocessibleEntity, "ASCII signature not compatible" unless @content.to_s.chomp[-5..-1] == PDF_ASCII_SIGNATURE
    rescue UnprocessibleEntity => e
      self.errors << { message: e.message }
    end
  end

  def file_extension
    begin
      raise UnprocessibleEntity, "Non-whitelist file extension" unless file_whitelist.select{|wl| wl == @extension }.any?
    rescue UnprocessibleEntity => e
      self.errors << { message: e.message }
    end
  end

end

