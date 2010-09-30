class ApplicationController < ActionController::Base
  unloadable
  helper :all
  protect_from_forgery
  
  include AuthenticatedSystem
  filter_parameter_logging :password
  before_filter :get_account
  before_filter :get_siteninja_config
  before_filter :cms_for_layout #, :only => [ :index, :show, :new, :create, :edit, :update, :comment, :forgot_password ]
  before_filter :init_search
  after_filter :find_menu
  $USA_STATES_ARRAY = [['Alabama', 'AL'], ['Alaska', 'AK'], ['Arizona', 'AZ'], ['Arkansas', 'AR'], ['California', 'CA'], ['Colorado', 'CO'], ['Connecticut', 'CT'], ['Delaware', 'DE'], ['District of Columbia', 'DC'], ['Florida', 'FL'], ['Georgia', 'GA'], ['Hawaii', 'HI'], ['Idaho', 'ID'], ['Illinois', 'IL'], ['Indiana', 'IN'], ['Iowa', 'IA'], ['Kansas', 'KS'], ['Kentucky', 'KY'], ['Louisiana', 'LA'], ['Maine', 'ME'], ['Maryland', 'MD'], ['Massachusetts', 'MA'], ['Michigan', 'MI'], ['Minnesota', 'MN'], ['Mississippi', 'MS'], ['Missouri', 'MO'], ['Montana', 'MT'], ['Nebraska', 'NE'], ['Nevada', 'NV'], ['New Hampshire', 'NH'], ['New Jersey', 'NJ'], ['New Mexico', 'NM'], ['New York', 'NY'], ['North Carolina', 'NC'], ['North Dakota', 'ND'], ['Ohio', 'OH'], ['Oklahoma', 'OK'], ['Oregon', 'OR'], ['Pennsylvania', 'PA'], ['Rhode Island', 'RI'], ['South Carolina', 'SC'], ['South Dakota', 'SD'], ['Tennessee', 'TN'], ['Texas', 'TX'], ['Utah', 'UT'], ['Vermont', 'VT'], ['Virginia', 'VA'], ['Washington', 'WA'], ['Wisconsin', 'WI'], ['West Virginia', 'WV'], ['Wyoming', 'WY']] unless const_defined?('USA_STATES_ARRAY')
  
  def render_404
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return
  end
  
  protected
  def get_account
    if ActiveRecord::Base.connection.tables.include?("accounts")
      unless domain_without_www.nil?  
        $CURRENT_ACCOUNT = Account.find_by_subdomain(domain_without_www) || render_404
      else
        $CURRENT_ACCOUNT = Account.find_by_name("master")
      end
      $ADMIN = false
    end
  end

  def domain_without_www
    request.subdomains.reject{|s| s =~ /^(www)$/}.first
  end
  
  def add_breadcrumb(name, url = '')
    @breadcrumbs ||= []
    name = eval(name) if name =~ /_path|_url|@/  
    url = eval(url) if url =~ /_path|_url|@/  
    @breadcrumbs << [name, url]  
  end  

  def self.add_breadcrumb(name, url, options = {})
    before_filter options do |controller|  
      controller.send(:add_breadcrumb, name, url)  
    end  
  end  
  
  private 
  def init_search
    @searches = Search.new
  end
  
  def cms_for_layout
    @menus = Menu.all
    @settings = Setting.first
    @footer_menus = Menu.find(:all, :conditions => {:show_in_footer => true}, :order => :footer_pos )
    session[:template] = params[:template][:id] if params[:template]
    @templates = ["demo", "t3c2", "t3c3", "t3c4", "t3c5", "t3c6", "t3c7", "t4c1", "t4c2", "t4c4", "t5c2", "t5c3", "t5c4", "t5c5", "t5c6", "t5c7"] if @cms_config['website']['demo']
  end
  
  def find_menu
    if @menu
      @featurable_sections = @menu.featurable_sections ? @menu.featurable_sections : ""
    end
  end
  
  def get_siteninja_config
    if $CURRENT_ACCOUNT
      get_subdomain_cms
    else
      @cms_config = YAML::load_file("#{RAILS_ROOT}/config/cms.yml")
    end
    if @cms_config["site_settings"]["restricted"] and !current_user and controller_name != "sessions"
      redirect_to(new_session_path)
    end
    @permissions = YAML::load_file("#{RAILS_ROOT}/config/permissions.yml")
    # "301 Redirect" to "www" for all live sites that are not parked or intended to be subdomains.
    unless @cms_config["site_settings"]["private"] or RAILS_ENV == "development"
      unless(@cms_config["site_settings"]["is_subdomain"] or self.request.subdomains[0] == "www" or self.request.domain.include?("site-ninja") or self.request.domain.include?("localhost") or @cms_config["website"]["domain"] == "site-ninja.com")
        redirect_to "http://www." + self.request.domain + request.request_uri
      else
        if @cms_config["website"]["domain"] == "site-ninja.com" and !(self.request.subdomains[0] == "www" or self.request.domain.include?("localhost") or self.request.domain.include?("127.0.0.1")) # Added specifically for site-ninja.com
          redirect_to "http://www." + self.request.domain + request.request_uri
        end
      end
    end
    if @cms_config["site_settings"]["private"] and !current_user and controller_name != "sessions"
      redirect_to(new_session_path)
    end
  end
  
  # Used in all administrative controllers to determine whether or not a user has access to it.
  def authorize(controller_access, controller_title)
    if current_user
      unless current_user.has_role(controller_access)
        flash[:error] = "You do not have access to #{controller_title}."
        begin
          redirect_to(:last)
        rescue
          redirect_to("/")
        end
      end
    else
      redirect_to(new_session_path)
    end
  end
  def get_subdomain_cms
    if $CURRENT_ACCOUNT.is_master?
      @cms_config = YAML::load_file("#{RAILS_ROOT}/config/cms.yml")
    else
      @cms_config = YAML::load_file("#{RAILS_ROOT}/config/subdomains/#{$CURRENT_ACCOUNT.subdomain}/cms.yml")
    end
  end
end
