###################################################################
#
# description:   database populator task for development use
# author:        Kip, Dave, Eric
# dependencies:  Populator and Faker gems (use `sudo gem install`)
# usage:         `rake db:populate` from your application's root
#
###################################################################

namespace :db do
  desc "Populate database with sweet, sweet dummy data."
  task :populate_subdomainify => :environment do
    @cms_config = YAML::load_file("#{RAILS_ROOT}/config/cms.yml")
    require 'populator'
    require 'faker'

    # these file contains video urls, pirate paragraphs, and useful methods like making permalinks.
    require "#{RAILS_ROOT}/vendor/plugins/siteninja/siteninja_core/lib/tasks/populate_urls.rb"
    require "#{RAILS_ROOT}/vendor/plugins/siteninja/siteninja_core/lib/tasks/populate_methods.rb"
    Account.create!(:name => "master")
    Account.create!(:name => "jason", :subdomain => "jason")
    Account.create!(:name => "jenn", :subdomain => "jenn")
    

    def fake_articles
      puts 'Faking articles...'
      [1, 2, 3].each do |account_id|
        $CURRENT_ACCOUNT = Account.find(account_id)
        ['Martial Arts','Spying','Assassination','Espionage','Illusion','Clothing/Image','Weapons & Tactics'].each do |ac|
          c = ArticleCategory.create!(:name => ac, :permalink => make_permalink(ac), :account_id => account_id)
        end
      end
      [1, 2, 3].each do |account_id|
        $CURRENT_ACCOUNT = Account.find(account_id)
        15.times do |i|
          user = User.all.rand # pick random author for article
          a = Article.new
          a.title = Faker::Company.bs.titleize
          puts "- \"#{a.title}\" by #{user.name}" if (i % 10 == 0)
          a.permalink = make_permalink(a.title)
          a.published_at = 10.days.from_now - rand(400).days
          a.published = (rand(10) != 0)
          a.notify_author_of_comments = true
          a.body = generate_random_body_content
          a.blurb = $BLURB # defined in generate_random_body_content
          a.description = $DESCRIPTION
          a.social_share = true
          a.created_at = Time.now - rand(450).days
          a.updated_at = a.created_at
          a.person_id = user.person.id
          a.account_id = account_id
          a.save!
        
          if a.published_at <= Time.now
            rand(10).times do
              c = a.comments.build # new comment for this article
              if rand(10) == 0
                # comment is from author
                c.name = user.name
                c.email = user.email
                c.user_id = user.person.id
              else
                # comment from blog visitor
                c.name = (rand(3) == 0 ? Faker::Name.first_name : Faker::Name.name)
                if rand(5) < 2
                  c.email = (rand(2) == 0 ? Faker::Internet.email : Faker::Internet.free_email)
                end
              end
              c.comment = random_pirate_paragraphs(1,1)
              c.created_at = Time.now - rand(((Time.now - a.published_at) / (60*60*24)).to_i.days)
              c.updated_at = c.created_at
              c.save!
            end
          end
        end
      end
      [1, 2, 3].each do |account_id|
        $CURRENT_ACCOUNT = Account.find(account_id) 
        make_tags(Article.all)
        
        Article.reset_column_information
        for article in Article.all
          Article.update_counters article.id, :comments_count => article.comments.size
          (rand(2)+1).times do
            # assign article to 1-2 categories
            c = ArticleCategory.all.sort_by(&:rand).first
            article.article_categories << c unless article.article_categories.include?(c)
          end
        end
      end
      $CURRENT_ACCOUNT = Account.find(1)
      article = Article.find_by_id(13)
      article.body = "#imagebox#<p>Okay, let\'s do them. Let\'s call your attention to the problem of corrupt quacks. Without going into all the gory details, let\'s just say that an armed revolt against Pirates are morally justified. However, I suspect that they are not yet strategically justified. I respect Pirates\' metanarratives, although their functionaries are too lazy to ensure that we survive and emerge triumphant out of the coming chaos and destruction. They just want to sit back, fasten their mouths on the public teats, and casually forget that ancient Greek dramatists discerned a peculiar virtue in being tragic. Pirates would do well to realize that they never discerned any virtue in being uncompanionable. Not only does Pirates tap into the national resurgence of overt unilateralism, but they then commands their patsies, \"Go, and do thou likewise.\"</p>
      <p>Pirates\' crusades are merely a stalking horse. They mask their secret intention to abrogate some of our most fundamental freedoms. If Pirates\' attempts to preach hatred have spurred us to send their sermons into the dustbin where they belong, then Pirates may have accomplished a useful thing. How I pity Pirates if I were to be their judge. I would start by notifying the jury that their unfortunate that Pirates have no real morals. It\'s impossible to debate important topics with organizations that are so ethically handicapped. Pirates have never gotten ahead because of their hard work or innovative ideas. Rather, all of Pirates\' successes are due to kickbacks, bribes, black market double-dealing, outright thuggery, and unsavory political intrigue.</p>
      <p>Just don\'t expect consistency from an organization that is completely and indeed nugatory. One might think that ignorance of the law does not excuse Pirates from the consequences of violating they, and this is, not surprisingly, the case. Simply put, Pirates cannot be tamed by \"tolerance\" and \"accommodation\" but is actually spurred on by such gestures. It sees such gestures as a sign of weakness on our part and is thereby encouraged to continue causing riots in the streets. Pirates\' accusations have merged with lexiphanicism in several interesting ways. Both spring from the same kind of reality-denying mentality. Both encourage every sort of indiscipline and degeneracy in the name of freedom. And both create a new cottage industry around their grumpy form of obstructionism.</p>"
      article.save!
      article = Article.find_by_id(14)
      article.body = "#imagebox#<p>Okay, let\'s do them. Let\'s call your attention to the problem of corrupt quacks. Without going into all the gory details, let\'s just say that an armed revolt against Pirates are morally justified. However, I suspect that they are not yet strategically justified. I respect Pirates\' metanarratives, although their functionaries are too lazy to ensure that we survive and emerge triumphant out of the coming chaos and destruction. They just want to sit back, fasten their mouths on the public teats, and casually forget that ancient Greek dramatists discerned a peculiar virtue in being tragic. Pirates would do well to realize that they never discerned any virtue in being uncompanionable. Not only does Pirates tap into the national resurgence of overt unilateralism, but they then commands their patsies, \"Go, and do thou likewise.\"</p>
      <p>Pirates\' crusades are merely a stalking horse. They mask their secret intention to abrogate some of our most fundamental freedoms. If Pirates\' attempts to preach hatred have spurred us to send their sermons into the dustbin where they belong, then Pirates may have accomplished a useful thing. How I pity Pirates if I were to be their judge. I would start by notifying the jury that their unfortunate that Pirates have no real morals. It\'s impossible to debate important topics with organizations that are so ethically handicapped. Pirates have never gotten ahead because of their hard work or innovative ideas. Rather, all of Pirates\' successes are due to kickbacks, bribes, black market double-dealing, outright thuggery, and unsavory political intrigue.</p>
      <p>Just don\'t expect consistency from an organization that is completely and indeed nugatory. One might think that ignorance of the law does not excuse Pirates from the consequences of violating they, and this is, not surprisingly, the case. Simply put, Pirates cannot be tamed by \"tolerance\" and \"accommodation\" but is actually spurred on by such gestures. It sees such gestures as a sign of weakness on our part and is thereby encouraged to continue causing riots in the streets. Pirates\' accusations have merged with lexiphanicism in several interesting ways. Both spring from the same kind of reality-denying mentality. Both encourage every sort of indiscipline and degeneracy in the name of freedom. And both create a new cottage industry around their grumpy form of obstructionism.</p>"
      article.save!
      article = Article.find_by_id(15)
      article.body = "#slideshow#<p>Okay, let\'s do them. Let\'s call your attention to the problem of corrupt quacks. Without going into all the gory details, let\'s just say that an armed revolt against Pirates are morally justified. However, I suspect that they are not yet strategically justified. I respect Pirates\' metanarratives, although their functionaries are too lazy to ensure that we survive and emerge triumphant out of the coming chaos and destruction. They just want to sit back, fasten their mouths on the public teats, and casually forget that ancient Greek dramatists discerned a peculiar virtue in being tragic. Pirates would do well to realize that they never discerned any virtue in being uncompanionable. Not only does Pirates tap into the national resurgence of overt unilateralism, but they then commands their patsies, \"Go, and do thou likewise.\"</p>
      <p>Pirates\' crusades are merely a stalking horse. They mask their secret intention to abrogate some of our most fundamental freedoms. If Pirates\' attempts to preach hatred have spurred us to send their sermons into the dustbin where they belong, then Pirates may have accomplished a useful thing. How I pity Pirates if I were to be their judge. I would start by notifying the jury that their unfortunate that Pirates have no real morals. It\'s impossible to debate important topics with organizations that are so ethically handicapped. Pirates have never gotten ahead because of their hard work or innovative ideas. Rather, all of Pirates\' successes are due to kickbacks, bribes, black market double-dealing, outright thuggery, and unsavory political intrigue.</p>
      <p>Just don\'t expect consistency from an organization that is completely and indeed nugatory. One might think that ignorance of the law does not excuse Pirates from the consequences of violating they, and this is, not surprisingly, the case. Simply put, Pirates cannot be tamed by \"tolerance\" and \"accommodation\" but is actually spurred on by such gestures. It sees such gestures as a sign of weakness on our part and is thereby encouraged to continue causing riots in the streets. Pirates\' accusations have merged with lexiphanicism in several interesting ways. Both spring from the same kind of reality-denying mentality. Both encourage every sort of indiscipline and degeneracy in the name of freedom. And both create a new cottage industry around their grumpy form of obstructionism.</p>"
      article.save!
      Image.create!(:title => "Katana", :viewable_id => 13, :viewable_type => "Article", :position => 8, :image_file_name => "00-7X128_2.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 54406)
      Image.create!(:title => "Sais", :viewable_id => 13, :viewable_type => "Article", :position => 5, :image_file_name => "20-2312_1.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 48938)
      Image.create!(:title => "Black sais", :viewable_id => 13, :viewable_type => "Article", :position => 6, :image_file_name => "325.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 47184)
      Image.create!(:title => "Katana on rack", :viewable_id => 13, :viewable_type => "Article", :position => 1, :image_file_name => "552119_craneall.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 136353)
      Image.create!(:title => "Custom katana hilt and sheath", :viewable_id => 13, :viewable_type => "Article", :position => 9, :image_file_name => "309358210_294f9bef3f_o.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 196056)
      Image.create!(:title => "Katana with blue hilt", :viewable_id => 13, :viewable_type => "Article", :position => 7, :image_file_name => "CC1b.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 1026876)
      Image.create!(:title => "Katana with blue hilt", :viewable_id => 13, :viewable_type => "Article", :position => 3, :image_file_name => "CC3b.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 774273)
      Image.create!(:title => "Katana with blue hilt", :viewable_id => 13, :viewable_type => "Article", :position => 2, :image_file_name => "CC6b.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 833113)
      Image.create!(:title => "Hilt", :viewable_id => 13, :viewable_type => "Article", :position => 10, :image_file_name => "crane5.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 369798)
      Image.create!(:title => "Katana", :viewable_id => 13, :viewable_type => "Article", :position => 4, :image_file_name => "Katana.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 813610)
      Image.create!(:title => "Katana with red hilt", :viewable_id => 13, :viewable_type => "Article", :position => 11, :image_file_name => "katana1.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 395697)
      Image.create!(:title => "Sais with red grips", :viewable_id => 13, :viewable_type => "Article", :position => 12, :image_file_name => "new_sai.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 2045549)
      Image.create!(:title => "Katana on glass", :viewable_id => 13, :viewable_type => "Article", :position => 13, :image_file_name => "original_208428_ODaM7fpFt7GnuTHkOFPEUQkr5.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 910418)
      Image.create!(:title => "Katana with purple hilt", :viewable_id => 13, :viewable_type => "Article", :position => 14, :image_file_name => "Weapons-Mitsurugi.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 37174)
      Image.create!(:title => "Afro Samurai", :viewable_id => 14, :viewable_type => "Article", :position => 2, :image_file_name => "wallpaper_afro_samurai_03_2560x1600.jpg", :image_content_type => "image/jpeg", :image_file_size => 965963)
      Image.create!(:title => "Samurai Showdown", :viewable_id => 14, :viewable_type => "Article", :position => 1, :image_file_name => "SamuraiShowdown.jpg", :image_content_type => "image/jpeg", :image_file_size => 537619)
      Image.create!(:title => "Samurai", :viewable_id => 14, :viewable_type => "Article", :position => 3, :image_file_name => "samurai_7_151_1280.jpg", :image_content_type => "image/jpeg", :image_file_size => 324232)
      Image.create!(:title => "Anime Ninja", :viewable_id => 14, :viewable_type => "Article", :position => 4, :image_file_name => "anime_ninja_1600x1200.jpg", :image_content_type => "image/jpeg", :image_file_size => 315351)
      Image.create!(:title => "Anime Ninja", :viewable_id => 14, :viewable_type => "Article", :position => 5, :image_file_name => "anime_ninja.jpg", :image_content_type => "image/jpeg", :image_file_size => 197893)
      Image.create!(:title => "Ninja Gaiden", :viewable_id => 14, :viewable_type => "Article", :position => 6, :image_file_name => "tgs-ninja-gaiden-sigma-2.jpg", :image_content_type => "image/jpeg", :image_file_size => 108714)
      Image.create!(:title => "Samurai", :viewable_id => 14, :viewable_type => "Article", :position => 7, :image_file_name => "628415samurai_x39.jpg", :image_content_type => "image/jpeg", :image_file_size => 151067)
      Image.create!(:title => "Red dragon", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 2, :image_file_name => "18402.jpg", :image_content_type => "image/jpeg", :image_file_size => 130157)
      Image.create!(:title => "White dragon", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 2, :image_file_name => "6501.jpg", :image_content_type => "image/jpeg", :image_file_size => 102335)
      Image.create!(:title => "Flames", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 2, :image_file_name => "17012.jpg", :image_content_type => "image/jpeg", :image_file_size => 115823)
      Image.create!(:title => "Tornado", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 1, :image_file_name => "17014.jpg", :image_content_type => "image/jpeg", :image_file_size => 202886)
      Image.create!(:title => "Armored", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 2, :image_file_name => "20366.jpg", :image_content_type => "image/jpeg", :image_file_size => 162303)
      Image.create!(:title => "Trident weapon", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 2, :image_file_name => "31532.jpg", :image_content_type => "image/jpeg", :image_file_size => 122087)
      Image.create!(:title => "Stealth", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 2, :image_file_name => "33404.jpg", :image_content_type => "image/jpeg", :image_file_size => 1184181)
      Image.create!(:title => "Nunchucku", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 2, :image_file_name => "33655.jpg", :image_content_type => "image/jpeg", :image_file_size => 148399)
      Image.create!(:title => "Sais", :caption => "Ninja halloween costume.", :viewable_id => 15, :viewable_type => "Article", :position => 2, :image_file_name => "34511.jpg", :image_content_type => "image/jpeg", :image_file_size => 246530)
      for article in Article.all
        unless article.images.empty?
          Feature.create!(:featurable_id => article.id, :featurable_type => "Article", :featurable_section_id => 1)
        end
      end
    end

    def fake_pages
      [1, 2, 3].each do |account_id|
        $CURRENT_ACCOUNT = Account.find(account_id)
        puts "Creating pages..."

        home = Page.create!(:account_id => account_id, :title => 'Home', :body => 'home',
          :meta_title => "Masters of Stealth and Content Management Systems", :permalink => "home", :can_delete => false, :position => 1)
          Page.create!(:account_id => account_id, :parent_id => home.id, :title => 'About Us', :body => 'About', :meta_title => "About SiteNinja.com")
          Page.create!(:account_id => account_id, :parent_id => home.id, :title => 'Members', :body => 'Members', :meta_title => "Members")
          contact_us = Page.create!(:parent_id => home.id, :title => 'Contact Us', :body => '<h1>Contact SiteNinja</h1>', :meta_title => "Contact SiteNinja.com")
          Page.create!(:account_id => account_id, :parent_id => home.id, :title => 'Contact Us - Thank You', :body => '<h1>Message sent!</h1><p>Thank you for submitting an inquiry. We usually respond within 2 business days by email.', :meta_title => "Message sent", :status => 'hidden', :show_in_footer => false)
          Page.create!(:account_id => account_id, :title => 'Blog', :meta_title => 'Blog', :body => "blog", :permalink => "blog", :can_delete => false) if @cms_config['modules']['blog']
          Page.create!(:account_id => account_id, :title => 'Products', :meta_title => 'Products', :body => "products", :can_delete => false) if @cms_config['modules']['product']
          Page.create!(:account_id => account_id, :title => 'Images', :meta_title => 'Galleries', :body => "galleries", :can_delete => false) if @cms_config['modules']['galleries']
           Page.create!(:account_id => account_id, :title => 'Links', :meta_title => 'Links', :body => "links", :can_delete => false) if @cms_config['modules']['links']
        # not ready for production use yet
        # if Rails.env.development? || Rails.env.test? #|| Rails.env.cucumber?
        #           Page.create!(:account_id => account_id, :title => 'Events', :meta_title => 'Events', :body => "events", :can_delete => false) if @cms_config['modules']['events']
        #           Page.create!(:title => 'Newsletters', :meta_title => 'Newsletters', :body => "Newsletters", :permalink => "newsletters", :can_delete => false, :status => "hidden") if @cms_config['modules']['newsletters']
        #           Page.create!(:title => 'Groups', :meta_title => 'Groups', :body => "Groups", :permalink => "groups", :can_delete => false, :show_in_footer => false, :status => "hidden") if @cms_config['modules']['newsletters']
        #           Page.create!(:title => 'People', :meta_title => 'People', :body => "People", :permalink => "people", :can_delete => false, :status => "hidden") if @cms_config['modules']['newsletters']
        #           Page.create!(:title => 'Blasts', :meta_title => 'Blasts', :body => "blasts", :permalink => "blasts", :can_delete => false, :status => "hidden") if @cms_config['modules']['newsletters']
        #           
        #           espi = Page.create!(:account_id => account_id, :title => 'Espionage', :body => 'Espionage', :meta_title => 'Espionage, Spies, and Technology', :show_in_footer => false)
        #           Page.create!(:account_id => account_id, :parent_id => espi.id, :title => 'Spies', :meta_title => 'Spies', :body => "Spies", :show_in_footer => false)
        #           Page.create!(:account_id => account_id, :parent_id => espi.id, :title => 'Technology and Techniques', :meta_title => 'Technology and Techniques', :body => "Techniques", :show_in_footer => false)
        #           
        #           martial = Page.create!(:account_id => account_id, :title => 'Martial Arts', :body => 'Martial Arts', :meta_title => 'Striking, Punching, and Kicking techniques', :show_in_footer => false)
        #           Page.create!(:account_id => account_id, :parent_id => martial.id, :title => 'Grappling', :body => 'Grappling', :meta_title => 'Grappling', :show_in_footer => false)
        #           Page.create!(:account_id => account_id, :parent_id => martial.id, :title => 'Weaponry', :body => 'Weaponry', :meta_title => 'Weaponry', :show_in_footer => false)
        #           
        #           striking = Page.create!(:account_id => account_id, :parent_id => martial.id, :title => 'Striking', :body => 'Martial Arts', :meta_title => 'Striking, Punching and Kicking', :show_in_footer => false)
        #           Page.create!(:account_id => account_id, :title => 'Documents and Forms', :meta_title => 'Documents and Forms', :parent_id => home.id, :body => 'Documents', :can_delete => false) if @cms_config['modules']['documents']
        #           Page.create!(:account_id => account_id, :parent_id => contact_us.id, :title => 'Privacy Policy',:show_articles => false, :show_events => false, :show_in_footer => true, :show_in_menu => false, :body => 'This page can be helpful when creating a privacy policy <a href="http://www.freeprivacypolicy.com/privacy.php">http://www.freeprivacypolicy.com/privacy.php</a>', :meta_title => "Privacy Policy")
        #           Page.create!(:account_id => account_id, :parent_id => contact_us.id, :title => 'Terms of Use', :show_articles => false, :show_events => false, :show_in_footer => true, :show_in_menu => false, :status => 'hidden', :body => 'Terms of Use', :meta_title => "Terms of Use")
        #           Page.create!(:title => 'Testimonials', :body => 'Testimonials', :meta_title => 'Testimonials', :show_in_footer => true, :can_delete => false, :parent_id => home.id, :account_id => account_id)
        #         end
        if @cms_config['features']['testimonials']
          testimonials = Page.create!(:title => 'Testimonials', :body => 'Testimonials', :meta_title => 'Testimonials', :show_in_footer => true, :can_delete => false, :parent_id => home.id, :account_id => account_id)
          Testimonial.create!(:author => "John Doe", :author_title => "Author, That Ninja Book", :quote => "This is a great resource for all things ninja-related!", :quotable_type => "Page", :quotable_id => testimonials.id, :feature => 'true', :account_id => account_id)
          Testimonial.create!(:author => "Joe Ninja", :author_title => "Blogger, Ninja Blog", :quote => "This site has everything I ever needed!", :quotable_type => "Page", :quotable_id => testimonials.id, :feature => 'true', :account_id => account_id)
          Testimonial.create!(:author => "Billy Bob", :author_title => "Every Day User", :quote => "I did a search regarding ninjas on google and found this to be the most complete resource available.", :quotable_type => "Page", :quotable_id => testimonials.id, :feature => 'true', :account_id => account_id)
          Testimonial.create!(:author => "Shredder", :author_title => "Villain", :quote => "With what I learned here, I'll have an insurmountable edge over those pesky turtles.", :quotable_type => "Page", :quotable_id => testimonials.id, :feature => 'true', :account_id => account_id)
         end
        
        
        for page in Page.all
          next if page.permalink == 'home' or page.permalink == 'inquire' or page.permalink == 'inquiry_received' or page.permalink == 'documents' or page.permalink == 'terms-of-use' or page.permalink == 'privacy-policy'
          page.permalink = make_permalink(page.meta_title)
          page.body = "<h1>#{page.meta_title}</h1>" + generate_random_body_content(true)
          page.save!
        end
        # home.update_attributes(
        #         :permalink => "home",
        #         :body => "<h1>#{home.meta_title}</h1>\n" + random_pirate_paragraphs(1,1,true) + "<p>http://vimeo.com/8706167</p>\n" + random_pirate_paragraphs(1,2,true) + "<p>http://vimeo.com/755450</p>\n" + random_pirate_paragraphs(2,4,true)
        #       )
        for page in Page.all
          if page.menus.empty?
            menu = page.menus.new
            menu.save!
          end
        end
        for menu in Menu.all
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
          menu.save!
        end
      end
    end

    def fake_assets

      puts "Adding assets..."
      # THESE MUST STAY IN THE SAME ORDER!
      Asset.create!(:name => "Black Ninja", :file_file_name => "ninja_black.png", :file_file_size => 37860)
      Asset.create!(:name => "Blue Ninja", :file_file_name => "ninja_blue.png", :file_file_size => 29432)
      Asset.create!(:name => "Brown Ninja", :file_file_name => "ninja_brown.png", :file_file_size => 35665)
      Asset.create!(:name => "Green Ninja", :file_file_name => "ninja_green.png", :file_file_size => 55034)
      Asset.create!(:name => "Orange Ninja", :file_file_name => "ninja_orange.png", :file_file_size => 36686)
      Asset.create!(:name => "Purple Ninja", :file_file_name => "ninja_purple.png", :file_file_size => 57344)
      Asset.create!(:name => "Red Ninja", :file_file_name => "ninja_red.png", :file_file_size => 42932)
      Asset.create!(:name => "White Ninja", :file_file_name => "ninja_white.png", :file_file_size => 39787)
    end

    def fake_documents
      top_folder = Folder.first
      Folder.create!(:title => "Ninja Clothing", :permalink => "ninja-clothing", :parent_id => top_folder.id)
      Folder.create!(:title => "Ninja Forms", :permalink => "ninja-forms", :parent_id => top_folder.id)
      Folder.create!(:title => "Robes", :permalink => "robes", :parent_id => 2)
      Folder.create!(:title => "Gi's'", :permalink => "gi-s", :parent_id => 2)
    end

    def fake_galleries
       puts "Creating galleries..."
       # THESE MUST STAY IN THE SAME ORDER!
       [1, 2, 3].each do |account_id|
         $CURRENT_ACCOUNT = Account.find(account_id)
         Gallery.create(:account_id => account_id, :title => "Weapons", :description => "A gallery of weapons used by ninjas.", :user_id => 1)
         Image.create(:account_id => account_id, :title => "Katana", :viewable_id => 1, :viewable_type => "Gallery", :position => 8, :image_file_name => "00-7X128_2.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 54406)
         Image.create(:account_id => account_id, :title => "Sais", :viewable_id => 1, :viewable_type => "Gallery", :position => 5, :image_file_name => "20-2312_1.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 48938)
         Image.create(:account_id => account_id, :title => "Black sais", :viewable_id => 1, :viewable_type => "Gallery", :position => 6, :image_file_name => "325.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 47184)
         Image.create(:account_id => account_id, :title => "Katana on rack", :viewable_id => 1, :viewable_type => "Gallery", :position => 7, :image_file_name => "552119_craneall.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 136353)
         Image.create(:account_id => account_id, :title => "Custom katana hilt and sheath", :viewable_id => 1, :viewable_type => "Gallery", :position => 9, :image_file_name => "309358210_294f9bef3f_o.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 196056)
         Image.create(:account_id => account_id, :title => "Katana with blue hilt", :viewable_id => 1, :viewable_type => "Gallery", :position => 1, :image_file_name => "CC1b.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 1026876)
         Image.create(:account_id => account_id, :title => "Katana with blue hilt", :viewable_id => 1, :viewable_type => "Gallery", :position => 3, :image_file_name => "CC3b.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 774273)
         Image.create(:account_id => account_id, :title => "Katana with blue hilt", :viewable_id => 1, :viewable_type => "Gallery", :position => 2, :image_file_name => "CC6b.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 833113)
         Image.create(:account_id => account_id, :title => "Hilt", :viewable_id => 1, :viewable_type => "Gallery", :position => 10, :image_file_name => "crane5.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 369798)
         Image.create(:account_id => account_id, :title => "Katana", :viewable_id => 1, :viewable_type => "Gallery", :position => 4, :image_file_name => "Katana.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 813610)
         Image.create(:account_id => account_id, :title => "Katana with red hilt", :viewable_id => 1, :viewable_type => "Gallery", :position => 11, :image_file_name => "katana1.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 395697)
         Image.create(:account_id => account_id, :title => "Sais with red grips", :viewable_id => 1, :viewable_type => "Gallery", :position => 12, :image_file_name => "new_sai.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 2045549)
         Image.create(:account_id => account_id, :title => "Katana on glass", :viewable_id => 1, :viewable_type => "Gallery", :position => 13, :image_file_name => "original_208428_ODaM7fpFt7GnuTHkOFPEUQkr5.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 910418)
         Image.create(:account_id => account_id, :title => "Katana with purple hilt", :viewable_id => 1, :viewable_type => "Gallery", :position => 14, :image_file_name => "Weapons-Mitsurugi.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 37174)
         
         Gallery.create(:account_id => account_id, :title => "Artwork", :user_id => 1, :description => "Various ninja-inspired artworks.")
         Image.create(:account_id => account_id, :title => "Afro Samurai", :viewable_id => 2, :viewable_type => "Gallery", :position => 1, :image_file_name => "wallpaper_afro_samurai_03_2560x1600.jpg", :image_content_type => "image/jpeg", :image_file_size => 965963)
         Image.create(:account_id => account_id, :title => "Samurai Showdown", :viewable_id => 2, :viewable_type => "Gallery", :position => 1, :image_file_name => "SamuraiShowdown.jpg", :image_content_type => "image/jpeg", :image_file_size => 537619)
         Image.create(:account_id => account_id, :title => "Samurai", :viewable_id => 2, :viewable_type => "Gallery", :position => 1, :image_file_name => "samurai_7_151_1280.jpg", :image_content_type => "image/jpeg", :image_file_size => 324232)
         Image.create(:account_id => account_id, :title => "Anime Ninja", :viewable_id => 2, :viewable_type => "Gallery", :position => 1, :image_file_name => "anime_ninja_1600x1200.jpg", :image_content_type => "image/jpeg", :image_file_size => 315351)
         Image.create(:account_id => account_id, :title => "Anime Ninja", :viewable_id => 2, :viewable_type => "Gallery", :position => 1, :image_file_name => "anime_ninja.jpg", :image_content_type => "image/jpeg", :image_file_size => 197893)
         Image.create(:account_id => account_id, :title => "Ninja Gaiden", :viewable_id => 2, :viewable_type => "Gallery", :position => 1, :image_file_name => "tgs-ninja-gaiden-sigma-2.jpg", :image_content_type => "image/jpeg", :image_file_size => 108714)
         Image.create(:account_id => account_id, :title => "Samurai", :viewable_id => 2, :viewable_type => "Gallery", :position => 1, :image_file_name => "628415samurai_x39.jpg", :image_content_type => "image/jpeg", :image_file_size => 151067)
         
         gallery_3 = Gallery.create(:account_id => account_id, :title => "Ninja Kids", :description => "Ninja halloween costumes.", :user_id => 1)
         Image.create(:account_id => account_id, :title => "Red dragon", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "18402.jpg", :image_content_type => "image/jpeg", :image_file_size => 130157)
         Image.create(:account_id => account_id, :title => "White dragon", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "6501.jpg", :image_content_type => "image/jpeg", :image_file_size => 102335)
         Image.create(:account_id => account_id, :title => "Flames", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "17012.jpg", :image_content_type => "image/jpeg", :image_file_size => 115823)
         Image.create(:account_id => account_id, :title => "Tornado", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "17014.jpg", :image_content_type => "image/jpeg", :image_file_size => 202886)
         Image.create(:account_id => account_id, :title => "Armored", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "20366.jpg", :image_content_type => "image/jpeg", :image_file_size => 162303)
         Image.create(:account_id => account_id, :title => "Trident weapon", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "31532.jpg", :image_content_type => "image/jpeg", :image_file_size => 122087)
         Image.create(:account_id => account_id, :title => "Stealth", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "33404.jpg", :image_content_type => "image/jpeg", :image_file_size => 1184181)
         Image.create(:account_id => account_id, :title => "Nunchucku", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "33655.jpg", :image_content_type => "image/jpeg", :image_file_size => 148399)
         Image.create(:account_id => account_id, :title => "Sais", :caption => "Ninja halloween costume.", :viewable_id => 3, :viewable_type => "Gallery", :position => 1, :image_file_name => "34511.jpg", :image_content_type => "image/jpeg", :image_file_size => 246530)
         gallery_3.update_attributes(:slideshow => true)
         for gallery in Gallery.all
           Feature.create(:featurable_id => gallery.id, :featurable_type => "Gallery", :featurable_section_id => 1, :account_id => account_id)
         end
       end
     end

    def fake_events
      puts 'Faking events...'
      i = 0
      Event.populate 30 do |e|

        e.name = Faker::Company.catch_phrase.titleize
        puts "- \"#{e.name}\"" if (i % 10 == 0)
        e.person_id = $USERS.rand.id
        e.address = "#{rand(1400)+100} State St, Santa Barbara, CA"
        e.description = generate_random_body_content
        e.blurb = $BLURB
        e.date_and_time = 3.months.ago..1.year.from_now
        e.images_count = 0
        e.features_count = 0
        if rand(4) == 0
          e.registration = true
          e.allow_cash = [true, false]
          e.allow_card = [true, false]
          e.allow_check = [true, false]
          e.payment_instructions = random_pirate_sentence
          if rand(2) == 0
            e.registration_limit = [10, 50, 100, 200, 500]
            e.registration_closed_text = Populator.paragraphs(1)
          else
            e.registration_limit = 0
          end
        end
        i = i + 1
      end

      puts 'Making permalinks...'
      for event in Event.all
        event.update_attribute(:permalink, make_permalink(event.name))
        EventPriceOption.populate rand(10) do |p|
          p.event_id = event.id
          p.description = Populator.words(1..2)
          p.price = [5.0, 10.0, 15.0, 20.0, 50.0, 100.0]
        end
      end
    end

    def fake_testimonials
      [1, 2, 3].each do |account_id|
        $CURRENT_ACCOUNT = Account.find(account_id)
        puts "Faking testimonials"
        Testimonial.create!(:author => Faker::Name.name, :author_title => Faker::Name.name, :quote => random_pirate_sentence, :quotable_type => "Product", :quotable_id => 1, :feature => 'false', :account_id => account_id)
        Testimonial.create!(:author => Faker::Name.name, :author_title => Faker::Name.name, :quote => random_pirate_sentence, :quotable_type => "Product", :quotable_id => 1, :feature => 'false', :account_id => account_id)
        Testimonial.create!(:author => Faker::Name.name, :author_title => Faker::Name.name, :quote => random_pirate_sentence, :quotable_type => "Product", :quotable_id => 1, :feature => 'false', :account_id => account_id)
      end
    end

    def fake_links
      ['Web Design','Martial Arts','Sabotage','Assassination','Espionage','Illusion','Clothing/Image','Weapons & Tactics'].each do |lc|
        c = LinkCategory.create!(:title => lc, :permalink => make_permalink(lc))
      end
      Link.create!(:title => "Ameravant", :link_category_id => 1, :url => "http://www.ameravant.com", :public => true, :featured => true, :blurb => "Ameravant prides themselves on building standards-based websites that are easy to use with cutting edge technology that gives you full control over your content.", :body => "Ameravant is an innovative web design and development company based in Santa Barbara, CA which was founded in 2001 by Michael Kramer. We specialize in creating content management systems for small and medium businesses. What does this mean? Basically, we put you in control of nearly every aspect of your website. We eliminate the need for you to contact us if you need a paragraph of text changed on your About Us page, or a new photo added to a slideshow you've made for a company event.")
      Link.create!(:title => "Site Ninja", :link_category_id => 2, :url => "http://www.site-ninja.com", :public => true, :featured => true, :blurb => "Site Ninja is a simple content management system.")
      Link.create!(:title => "Ninja on Wikipedia", :link_category_id => 2, :url => "http://en.wikipedia.org/wiki/Ninja", :public => true, :featured => true, :blurb => "A ninja or shinobi was a covert agent or mercenary of feudal Japan specializing in unorthodox arts of war. The functions of the ninja included espionage, sabotage, infiltration, assassination, as well as open combat in certain situations. The underhanded tactics of the ninja were contrasted with the samurai, who were careful not to tarnish their reputable image.", :body => "The origin of the ninja is obscure and difficult to determine, but can be surmised to be around the 14th century. Few written records exist to detail the activities of the ninja. The word shinobi did not exist to describe a ninja-like agent until the 15th century, and it is unlikely that spies and mercenaries prior to this time were seen as a specialized group. In the unrest of the Sengoku period (15th - 17th centuries), mercenaries and spies for hire arose out of the Iga and Kōga regions of Japan, and it is from these clans that much of later knowledge regarding the ninja is inferred. Following the unification of Japan under the Tokugawa shogunate, the ninja descended again into obscurity. However, in the 17th and 18th centuries, manuals such as the Bansenshukai (1676) — often centered around Chinese military philosophy — appeared in significant numbers. These writings revealed an assortment of philosophies, religious beliefs, their application in warfare, as well as the espionage techniques that form the basis of the ninja's art. The word ninjutsu would later come to describe a wide variety of practices related to the ninja.")
      Link.create!(:title => "Espionage on Wikipedia", :link_category_id => 5, :url => "http://en.wikipedia.org/wiki/Espionage", :public => true, :featured => true, :blurb => "Espionage or spying involves an individual obtaining information that is considered secret or confidential without the permission of the holder of the information.", :body => "Espionage or spying involves an individual obtaining information that is considered secret or confidential without the permission of the holder of the information. Espionage is inherently clandestine, as the legitimate holder of the information may change plans or take other countermeasures once it is known that the information is in unauthorized hands. See clandestine HUMINT for the basic concepts of such information collection, and subordinate articles such as clandestine HUMINT operational techniques and clandestine HUMINT asset recruiting for discussions of the \"tradecraft\" used to collect this information.")
      Link.create!(:title => "Sabotage", :link_category_id => 3, :url => "http://en.wikipedia.org/wiki/Sabotage", :blurb => "Sabotage is a deliberate action aimed at weakening another entity through subversion, obstruction, disruption, and/or destruction. In a workplace setting, sabotage is the conscious withdrawal of efficiency generally directed at causing some change in workplace conditions. One who engages in sabotage is a saboteur.", :public => true, :featured => true)
      for link in Link.all
        link.permalink = make_permalink(link.title)
        link.save!
      end
      make_tags(Link.all)
    end

    def fake_products
      puts "Faking products..."
      ProductCategory.create!(:name => 'Ninja Weapons', :permalink => 'ninja-weapons')
      ProductCategory.create!(:name => 'Ninja Stealth Products', :permalink => 'ninja-stealth-products')
      Product.populate 10 do |p|
        p.title = Faker::Company.catch_phrase.titleize
        p.permalink = make_permalink(p.title)
        p.description = random_pirate_paragraphs(at_least=1, at_most=2, for_html=false)
        p.blurb = random_pirate_sentence
        p.featured = true if rand(10) == 0
        p.images_count = 0
        p.features_count = 0
        p.display_add_cart = 1
        p.active = true
        p.deleted = false
        p.created_at = 1.year.ago..Time.now
        p.updated_at = p.created_at
        po = ProductOption.new(:price => rand(30), :available => true)
        po.save!
        p.product_options << po
        p.save!
      end

      for product in Product.all
        product.product_categories <<  ProductCategory.find(rand(ProductCategory.count) + 1)
      end
      Image.create!(:title => "Katana", :viewable_id => 1, :viewable_type => "Product", :position => 8, :image_file_name => "00-7X128_2.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 54406)
      Image.create!(:title => "Sais", :viewable_id => 2, :viewable_type => "Product", :position => 5, :image_file_name => "20-2312_1.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 48938)
      Image.create!(:title => "Black sais", :viewable_id => 3, :viewable_type => "Product", :position => 6, :image_file_name => "325.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 47184)
      Image.create!(:title => "Katana on rack", :viewable_id => 4, :viewable_type => "Product", :position => 1, :image_file_name => "552119_craneall.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 136353)
      Image.create!(:title => "Custom katana hilt and sheath", :viewable_id => 5, :viewable_type => "Product", :position => 9, :image_file_name => "309358210_294f9bef3f_o.jpg.jpeg", :image_content_type => "image/jpeg", :image_file_size => 196056)

    end

    def fake_orders
      Order.create!()
    end

    def fake_inquiries
      puts 'Faking inquiries...'
      Inquiry.populate 10 do |i|
        i.name = [Faker::Name.name, Faker::Name.name, Faker::Name.first_name]
        i.email = [Faker::Internet.email, Faker::Internet.free_email]
        i.phone = [nil, nil, Faker::PhoneNumber.phone_number]
        i.inquiry = random_pirate_paragraphs(at_least=1, at_most=2, for_html=false)
        i.created_at = 6.months.ago..Time.now
        i.updated_at = i.created_at
      end
    end

    puts 'Adding role groups...'
      [1, 2, 3].each do |account_id|
        $CURRENT_ACCOUNT = Account.find(account_id)
        admin = PersonGroup.create!(:title => "Admin", :role => true, :public => false, :description => "Has access to all areas of the CMS.", :account_id => account_id)
        author = PersonGroup.create!(:title => "Author", :role => true, :public => false, :description => "Can write and publish their own articles.", :account_id => account_id)
        editor = PersonGroup.create!(:title => "Editor", :role => true, :public => false, :description => "Can write, edit, and publish any article, and moderates comments.", :account_id => account_id)
        contributor = PersonGroup.create!(:title => "Contributor", :role => true, :public => false, :description => "Can write their own articles, but cannot publish them.", :account_id => account_id)
        moderator = PersonGroup.create!(:title => "Moderator", :role => true, :public => false, :description => "Can moderate comments.", :account_id => account_id)
        member = PersonGroup.create!(:title => "Member", :role => true, :public => false, :description => "Has access to member areas.", :account_id => account_id)
        newsletter = PersonGroup.create!(:title => "Newsletter", :role => false, :public => true, :description => "Subscribe to the newsletter.", :account_id => account_id)
        puts 'Adding users...'
      end

    # actually do stuff here...
    [1, 2, 3].each do |account_id|
      $CURRENT_ACCOUNT = Account.find(account_id)
      person = Person.create!(:first_name => "admin-#{account_id}", :last_name => "admin-#{account_id}", :email => "admin-#{account_id}@mailinator.com", :account_id => account_id)
      person.person_groups << PersonGroup.find_by_title("Admin")
      user = User.create!(:login => "admin-#{account_id}", :password => "admin#{account_id}", :password_confirmation => "admin#{account_id}", :active => true, :account_id => account_id)
      user.person_id = person.id
      user.save!
            
      person = Person.create!(:first_name => "John", :last_name => "Doe", :email => "johndoe@mailinator.com", :account_id => account_id)
      person.person_groups << PersonGroup.find_by_title("Member")
      user = User.create!(:login => 'member', :password => 'member', :password_confirmation => 'member', :active => true, :account_id => account_id)
      user.person_id = person.id
      user.save!
      
      person = Person.create!(:first_name => "Donatello", :last_name => "Turtle", :email => "donatello@mailinator.com", :account_id => account_id)
      person.person_groups << PersonGroup.find_by_title("Author")
      user = User.create!(:login => 'donatello', :password => 'donatello', :password_confirmation => 'donatello', :active => true, :account_id => account_id)
      user.person_id = person.id
      user.save!
      
      person = Person.create!(:first_name => "Raphael", :last_name => "Turtle", :email => "raphael@mailinator.com", :account_id => account_id)
      person.person_groups << PersonGroup.find_by_title("Editor")
      user = User.create!(:login => 'raphael', :password => 'raphael', :password_confirmation => 'raphael', :active => true, :account_id => account_id)
      user.person_id = person.id
      user.save!
      
      user = person = Person.create!(:first_name => "Michaelangelo", :last_name => "Turtle", :email => "michaelangelo@mailinator.com", :account_id => account_id)
      person.person_groups << PersonGroup.find_by_title("Contributor")
      michaelangelo = User.create!(:login => 'michaelangelo', :password => 'michaelangelo', :password_confirmation => 'michaelangelo', :active => true, :account_id => account_id)
      michaelangelo.update_attribute(:can_deactivate, false)
      michaelangelo.person_id = person.id
      michaelangelo.save!
      
      person = Person.create!(:first_name => "Leonardo", :last_name => "Turtle", :email => "leonardo@mailinator.com", :account_id => account_id)
      person.person_groups << PersonGroup.find_by_title("Admin")
      user = User.create!(:login => 'leonardo', :password => 'leonardo', :password_confirmation => 'leonardo', :active => true, :account_id => account_id)
      user.person_id = person.id
      user.save!
    end
    def fake_featurable_sections
      [2, 3].each do |account_id|
        $CURRENT_ACCOUNT = Account.find(account_id)
        fs = FeaturableSection.new(:title => "Home Page Feature Box", :image_required => true, :site_wide => false, :account_id => account_id)
      end 
    end
    

    $USERS = User.all

    Setting.create!(
      :newsletter_from_email => 'admin@ameravant.com',
      :footer_text => '<p style="text-align: center;">&copy; 2008-#YEAR# Site-Ninja.com</p>
<p style="text-align: center;"><a href="/" class="icon"><img title="SiteNinja Homepage" src="/system/files/1/thumb/ninja_black.png" alt="Black Ninja" width="48" height="45" border="0" /></a></p>',
      :inquiry_notification_email => "contact@ameravant.com",
      :comment_profanity_filter => true,
      :events_range => 3,
      :tracking_code => '<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src=\'" + gaJsHost + "google-analytics.com/ga.js\' type=\'text/javascript\'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-7311013-1");
pageTracker._trackPageview();
} catch(err) {}</script>'
    )
    fake_assets # keep this line first
    fake_pages
    Page.all.collect{|p| p.save!}
    fake_events if @cms_config['modules']['events']
    fake_articles if @cms_config['modules']['blog']
    fake_galleries if @cms_config['modules']['galleries']
    
    # fake_documents if @cms_config['modules']['documents']
    # fake_links if @cms_config['modules']['links']
#    fake_inquiries
    # fake_products if @cms_config['modules']['product']
    fake_testimonials if @cms_config['modules']['product']
    fake_featurable_sections
    
    # fs = FeaturableSection.first
    #     m = Menu.first
    #     if m and fs
    #       m.featurable_sections << fs
    #       m.save
    #     end
    

  end
end

