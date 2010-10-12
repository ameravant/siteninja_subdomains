class Admin::AccountsController < AdminController
  # before_filter :super_admin_check
  # before_filter :clear_current_account, :only => :index
  before_filter :find_account, :only => [:edit, :update, :delete]
  def index
    @accounts = Account.all
  end
  def new
    @account = Account.new
  end
  def edit
  end
  def create
    @account = Account.new(params[:account])
    @master_settings = Account.master.first.setting
    if @account.save
      add_cms_to_shared
      add_basic_data
      redirect_to "http://#{@account.subdomain}.#{@cms_config['website']['domain']}"
      flash[:notice] = "You've created a successful account"
    else
      render :new
    end
  end
  
  private
  def add_cms_to_shared
    if Rails.env.production?
      path = RAILS_ROOT.gsub(/(\/data\/)(\S*)\/releases\S*/, '\1\2')
      make_initial_subdomain_folder(path) unless File.exists?("#{path}/config/subdomains") && File.exists?("#{path}/shared/config")
      system "mkdir #{path}/current/config/subdomains/#{@account.subdomain}"
      system "mv #{path}/current/config/subdomains/#{@account.subdomain} #{path}/shared/config/subdomains/"
      system "ln -s #{path}/shared/config/subdomains/#{@account.subdomain} #{path}/current/config/subdomains/#{@account.subdomain}"
      system "cp #{path}/current/config/cms.yml #{path}/shared/config/subdomains/#{@account.subdomain}/cms.yml"
      cms_yml = YAML::load_file("#{path}/current/config/subdomains/#{@account.subdomain}/cms.yml")
      cms_yml['website']['name'] = "#{@account.name.strip}"
      File.open("#{path}/current/config/subdomains/#{@account.subdomain}/cms.yml", 'w') { |f| YAML.dump(cms_yml, f) }
    else
      path = RAILS_ROOT
      make_initial_subdomain_folder(path) unless File.exists?("#{path}/config/subdomains") && File.exists?("#{path}/shared/config")
      system "mkdir #{path}/config/subdomains/#{@account.subdomain}"
      system "cp #{path}/config/cms.yml #{path}/config/subdomains/#{@account.subdomain}/cms.yml"
      cms_yml = YAML::load_file("#{path}/config/subdomains/#{@account.subdomain}/cms.yml")
      cms_yml['website']['name'] = "#{@account.name.strip}"
      File.open("#{path}/config/subdomains/#{@account.subdomain}/cms.yml", 'w') { |f| YAML.dump(cms_yml, f) }
    end
  end
  
  def make_initial_subdomain_folder(path)
    if Rails.env.production?
      system "mkdir #{path}/current/config/subdomains" unless File.exists?("#{path}/shared/config/subdomains")
      system "mv #{path}/current/config/subdomains #{path}/shared/config/subdomains" unless File.exists?("#{path}/shared/config/subdomains")
      system "ln -s #{path}/shared/config/subdomains #{path}/current/config/subdomains"
    else
      system "mkdir #{path}/config/subdomains" unless File.exists?("#{path}/shared/config/subdomains")
    end
  end
  def add_basic_data
    clear_current_account
    system "rake db:populate_subdomainify_min"
    Account.last.setting.update_attributes(@master_setting.attributes)
  end
  def clear_current_account
    $CURRENT_ACCOUNT = nil
    $CURRENT_ACCOUNT = Account.find(params[:account_id]) if params[:account_id]
  end
  def super_admin_check
    redirect_to '/' unless current_user && current_user.login == "admin"
  end
  def find_account
    @account = Account.find(params[:id])
  end
end