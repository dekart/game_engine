window.ItemHelper =
  itemAmountSelector: (item)->
    result = '<select>'

    for amount in [1, 5, 10, 25, 50, 100]
      result += "<option value='#{ amount }'>#{ amount }</option>"

    result += '</select>'

    @safe result

  itemPackage: (item)->
    if item.package_size > 1
      @safe """
        <span class="package_size">
          #{ I18n.t('shop.package_size', amount: item.package_size) }
          <a class="help" href="/help_pages/item_package">&nbsp;</a>
        </span>
      """
    else
      ''
