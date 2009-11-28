module FlashBlockHelper
  DISPLAY_KEYS = [:success, :error, :notice]

  def flash_block(*args, &block)
    options = args.extract_options!
    display_keys = args.any? ? args : DISPLAY_KEYS

    result = ""

    display_keys.each do |key|
      unless flash[key].blank?
        value = block_given? ? capture(flash[key], &block) : flash[key]

        result << content_tag(:div, value,
          options.reverse_merge(:id => :flash, :class => key)
        )
      end
    end

    result.html_safe!

    block_given? ? concat(result) : result
  end
end