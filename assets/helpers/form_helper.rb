module FormHelper

  def form_tag(url_for_options = {}, options = {}, &block)
    @form = String.new
    <<-HTML
      <form action=\"#{url_for_options}\" method=\"#{options[:method]}\">
        #{@form << block.call}
      </form>
    HTML
  end

  def text_field_tag(name, value = nil, options = {})
    @form << <<-HTML
      <input type=\"text\" name=\"#{name}\" value=\"#{value ? value : ""}\" #{options.map{|k, v| "#{k}=\"#{v}\""} } />
    HTML
  end

  def submit_tag(name)
    @form << <<-HTML
      <input type=\"submit\" name=\"#{name}\" />
    HTML
  end

end
