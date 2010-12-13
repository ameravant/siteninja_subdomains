module SubdomainsHelper
#restricted settings list is stored in the cms.yml
  def setting_restricted?(setting)
    @cms_config['site_settings']['restricted_fields'] && @cms_config['site_settings']['restricted_fields'].include?(setting.to_s) && !$CURRENT_ACCOUNT.is_master?
  end
end
#push this helper into the application
ApplicationHelper.send(:include, SubdomainsHelper)