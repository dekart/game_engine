class RedirectFromIframeTo
  def initialize(expected)
    @expected = expected
  end

  def matches?(controller)
    if controller.body =~ /window.top.location.href = #{ @expected.to_json };/
      true
    else
      @actual = controller.body.match(/window.top.location.href = "(.*)";/)[1]
      false
    end
  end

  def failure_message
    return ["expected iframe redirect to #{@expected.inspect}", @actual ? "redirected to '#{@actual}' instead" : 'got no redirect'].join(', ')
  end
   
  def negeative_failure_message
    return ["expected no iframe redirect to #{@expected.inspect}", @actual ? "got redirect to #{@actual}" : nil].compact.join(', ')
  end
end


def redirect_from_iframe_to(expected)
  RedirectFromIframeTo.new(expected)
end
