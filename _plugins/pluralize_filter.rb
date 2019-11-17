module Jekyll
  module PluralizeFilter
    def pluralize(input, singular, plural)
      if input.to_i < 2
        "#{singular}"
      else
        "#{plural}"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::PluralizeFilter)