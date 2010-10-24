module Admin::BoostsHelper
  def boost_image(boost, format, options = {})
    if boost.image?
      image_tag(boost.image.url(format), options.reverse_merge(:alt => boost.name, :title => boost.name))
    else
      boost.name
    end
  end
end
