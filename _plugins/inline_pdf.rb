module Jekyll
  module InlinePDF
    def pdf(input)
      path = "assets/uploads/#{input}"
      if File.exist?(path)
        output = "<iframe src='/#{path}' width='100%' height='600px'"
        output << " frameborder='0' class='my-2' "
        output << ' style="border: none;">'
        output << "</iframe>"
        output
      else
        "Arquivo não encontrado: #{input}"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::InlinePDF)
