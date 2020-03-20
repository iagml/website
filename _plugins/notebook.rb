module Jekyll
  module NotebookFilter
    def notebook(input)
      path = "notebooks/#{input}.html"

      if File.exist?(path)
        output = '<iframe src="/notebooks/' + input + '.html" '
        output << ' frameborder="0" scrolling="no" '
        output << ' onload="this.height=this.contentWindow.document.body.scrollHeight;" '
        output << ' style="width: 100%; border:none; overflow: auto;"></iframe>'
        output
      else
        "<pre><code>Arquivo: \"#{input}\" não encontrado</code></pre>"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::NotebookFilter)