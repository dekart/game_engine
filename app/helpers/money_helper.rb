module MoneyHelper
  def basic_money_tag(basic_money)
    content_tag(:span, basic_money, :class => :basic_money)
  end
  
  def vip_money_tag(vip_money)
    content_tag(:span, vip_money, :class => :vip_money)
  end
end