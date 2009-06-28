module FacebookPaginator
  class TemplateProxy
    def initialize(template)
      @template = template
    end

    def params
      return @params unless @params.nil?
      
      returning @params = HashWithIndifferentAccess.new do
        @template.params.each_pair do |key, value|
          @params[key] = nil if key.to_s.starts_with?("fb_sig")
        end
      end
    end

    def method_missing(*args)
      @template.send(*args)
    end
  end

  class LinkRenderer < WillPaginate::LinkRenderer
    def prepare(collection, options, template)
      super(collection, options, TemplateProxy.new(template))
    end
  end
end