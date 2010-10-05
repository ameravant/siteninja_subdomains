class Admin::SettingsController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authorization
  before_filter :get_settings
  add_breadcrumb "Settings", nil

  def stylesheet
    respond_to do |wants|
      wants.css
    end
  end
  
  def edit
  end

  def update
    if params[:settings][:remove_newsletter_logo] == "1"
      @settings.newsletter_logo, params[:settings][:newsletter_logo] = nil
    end
    if params[:header_right_remove] == "1"
      @settings.header_right, params[:settings][:header_right] = nil
      @settings.header_right, params[:settings][:header_right_url] = nil
    end
    if params[:favicon_remove] == "1"
      @settings.favicon, params[:settings][:favicon] = nil
    end
    if params[:logo_remove] == "1"
      @settings.logo, params[:settings][:logo] = nil
    end
    @cms_config['site_settings']['feature_box_overlay_position'] = params[:cms][:feature_box_overlay_position]
    @cms_config['site_settings']['signup_title'] = params[:cms][:signup_title]
    @cms_config['site_settings']['signup_description'] = params[:cms][:signup_description]
    @cms_config['site_settings']['links_title'] = params[:cms][:links_title] unless params[:cms][:links_title].blank?
    @cms_config['site_settings']['events_title'] = params[:cms][:events_title] unless params[:cms][:events_title].blank?
    @cms_config['site_settings']['event_title'] = params[:cms][:event_title] unless params[:cms][:event_title].blank?
    @cms_config['site_settings']['blog_title'] = params[:cms][:blog_title] unless params[:cms][:blog_title].blank?
    @cms_config['site_settings']['article_title'] = params[:cms][:article_title] unless params[:cms][:article_title].blank?
    @cms_config['site_settings']['show_past_events'] = params[:cms][:show_past_events]? true : false 
    @cms_config['site_settings']['wide_feature_box'] = params[:cms][:wide_feature_box]? true : false 
    @cms_config['site_settings']['private'] = params[:cms][:private]? true : false 
    @cms_config['keys']['google_maps'] = params[:cms][:google_maps]
    @cms_config['site_settings']['google_merchant_id'] = params[:cms][:google_merchant_id]
    @cms_config['site_settings']['sendgrid_username'] = params[:cms][:sendgrid_username] unless params[:cms][:sendgrid_username].blank?
    @cms_config['site_settings']['sendgrid_password'] = params[:cms][:sendgrid_password] unless params[:cms][:sendgrid_password].blank?
    @cms_config['site_settings']['restricted_fields'] = params[:cms][:restricted_fields] if params[:cms][:restricted_fields] 

    File.open("#{RAILS_ROOT}/config/cms.yml", 'w') { |f| YAML.dump(@cms_config, f) }
    if @settings.update_attributes(params[:settings])
      update_all_setting_records if $CURRENT_ACCOUNT.is_master?
      flash[:notice] = "Settings have been updated."
      system("touch tmp/restart.txt")
      redirect_to edit_admin_setting_path
    else
      render :action => "edit"
    end
  end

  def updater
    # Update plugin urls before cloning and pulling from git.
    plugin_urls = "'" + Plugin.all.reject { |c| }.map { |c| "#{c.url}" }.join(", ") + "'"
    plugins = "[ :all, " + Plugin.all.reject { |c| }.map { |c| ":#{get_git_directory(c.url)}" }.join(", ") + " ]"
    @cms_config['site_settings']['plugin_urls'] = plugin_urls
    @cms_config['site_settings']['plugins'] = plugins
    File.open("#{RAILS_ROOT}/config/cms.yml", 'w') { |f| YAML.dump(@cms_config, f) }
    system("rake rails:template LOCATION=#{RAILS_ROOT}/vendor/plugins/siteninja/siteninja_core/siteninja_updater.rb")
    system("rake rails:template LOCATION=#{RAILS_ROOT}/vendor/plugins/siteninja/siteninja_core/siteninja_updater_2.rb")
    system("touch tmp/restart.txt")
    if @cms_config['website']['demo']
      system("rake db:drop db:create db:migrate db:populate")
    end
    flash[:notice] = "SiteNinja Modules are up to date."
    redirect_to "/admin/setting/edit"
  end

  def update_menus
    for page in Page.all
      if page.menus.empty?
        menu = page.menus.new
        menu.save
      end
    end
    for menu in Menu.all
      if menu.navigatable_type == "Page"
        page = menu.navigatable
        unless page.parent_id.blank?
          parent_page = Page.find(page.parent_id)
          menu.parent_id = parent_page.menus.first.id
        end
        menu.position = page.position
        menu.footer_pos = page.footer_pos
        menu.show_in_footer = page.show_in_footer
        menu.can_delete = page.can_delete
        menu.status = page.status
        menu.save
      end
    end
    flash[:notice] = "SiteNinja menus are go!"
    redirect_to "/admin/setting/edit"
  end

    
  def preview
    render :layout => false
    @owner = eval(params[:owner_type]).find_by_id(params[:owner_id])
    @preview = params[:preview]
  end

  private
  def update_all_setting_records
    Setting.get_all_settings.reject{|c| c.account.is_master?}.each do |setting|
      settings = {}
      for key in params[:settings].keys
        if @cms_config['site_settings']['restricted_fields'].include?(key.to_s)
          settings[key] = params[:settings][key] # @master_settings.send(key.to_sym)
          setting.update_attributes(settings)
        end
      end
      cms_config = YAML::load_file("#{RAILS_ROOT}/config/subdomains/#{setting.account.subdomain}/cms.yml")
      for key in params[:cms].keys
        if @cms_config['site_settings']['restricted_fields'].include?(key.to_s)
          cms_config['site_settings'][key.to_s] = @cms_config['site_settings'][key.to_s]
        end
      end
      cms_config['site_settings']['restricted_fields'] = @cms_config['site_settings']['restricted_fields']
      File.open("#{RAILS_ROOT}/config/subdomains/#{setting.account.subdomain}/cms.yml", 'w') { |f| YAML.dump(cms_config, f) }
    end
  end

  def get_settings
    @settings = Setting.find_by_account_id($CURRENT_ACCOUNT.id)
  end

  def authorization
    authorize(@permissions['settings'], "Settings")
  end

end

