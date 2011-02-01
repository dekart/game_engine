module SettingSpecHelper
  def with_setting(key, value)
    old_value = Setting[key]
    
    Setting[key] = value
    Setting.update_cache!(true)
    
    yield
    
    Setting[key] = old_value
    Setting.update_cache!(true)
  end
end