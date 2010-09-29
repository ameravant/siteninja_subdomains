module SubdomainsHelper
  def setting_restricted?(setting)
    @cms_config['site_settings']['restricted_fields'] && @cms_config['site_settings']['restricted_fields'].include?(setting.to_s) && !$CURRENT_ACCOUNT.is_master?
  end
end
ApplicationHelper.send(:include, SubdomainsHelper)