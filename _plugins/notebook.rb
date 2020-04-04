module Jekyll
  module NotebookFilter
    def notebook(input)
      path = "notebooks/#{input}.html"

      if File.exist?(path)
        output = '<div>'
        output << "<a href=\"https://colab.research.google.com/github/iagml/iagml.github.io/blob/master/assets/uploads/#{input}.ipynb\">"
        output << '<img class="mt-5" src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab" />'
        output << '</a>'
        output << "<iframe src=\"/notebooks/#{input}.html\" "
        output << ' frameborder="0" scrolling="no" '
        output << ' onload="this.height=this.contentWindow.document.body.scrollHeight;" '
        output << ' style="width: 100%; border:none; overflow: auto;"></iframe>'
        output << '</div>'
        output
      else
        "<pre><code>Arquivo: \"#{input}.ipynb\" não encontrado</code></pre>"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::NotebookFilter)