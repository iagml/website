require 'active_support/core_ext/string'

module Jekyll
  module ParameterizeFilter
    def parameterize(input)
      "#{input.parameterize}"
    end
  end
end

Liquid::Template.register_filter(Jekyll::ParameterizeFilter)