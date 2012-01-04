module MoneyHelper
  def basic_money_tag(value)
    (
      '<span class="basic_money">%s</span>' % value
    ).html_safe
  end

  def vip_money_tag(value)
    (
      '<span class="vip_money">%s</span>' % value
    ).html_safe
  end
end