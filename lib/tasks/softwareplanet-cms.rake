#encoding: utf-8 

##  Main setup script wizard. Run it once, with "rake cms:setup" command
##  All rights reserved, InterLink © 2000-2013

require 'io/console'

desc "Setup script"

  namespace :cms do    

    # Installation script wizard should be able to roll back if the last run was not successful.
    task :wizard do
      
      UI_DELAY = 0

      DATABASE_CHECKING = true

      OWNER_RAILS_ROOT=Rails.root.to_s
      OWNER_GEMFILE_PATH = OWNER_RAILS_ROOT + '/Gemfile'
      OWNER_SEED_FILE_PATH = OWNER_RAILS_ROOT + '/db/seeds.rb'    
      OWNER_ROUTE_FILE_PATH = OWNER_RAILS_ROOT + '/config/routes.rb'
      OWNER_APP_JS_PATH = OWNER_RAILS_ROOT + '/app/assets/javascripts/application.js'
      OWNER_APP_CSS_PATH = OWNER_RAILS_ROOT + '/app/assets/stylesheets/application.css'
      
      #
      # Wizard menu (todo):
      #
      
      puts "***Welcome to Cms setup Wizard. What is your wish?"
      puts "1 - Setup Cms for current project."
      puts "0 - Exit Wizard"
      user_choice = STDIN.gets
      puts user_choice.inspect
      exit if user_choice != "1\n"

      #
      # Touch the database:
      #
      if DATABASE_CHECKING
        @database_status_OK = nil
        puts "..";sleep UI_DELAY;puts("Check your database status...");sleep UI_DELAY;
        begin
          Rake::Task['db:migrate'].reenable
          Rake::Task['db:migrate'].invoke
          @database_status_OK = true
        rescue => e
          puts "****** Database migrate error: " + e.to_s
          exit if e.to_s.index("Unknown database") == nil
          puts "rake db:create first!"
          @database_status_OK = false
        end

        if @database_status_OK == false
          begin
            puts "Dont worry. It seems that your database was not prepeared yet. May I create it manually with rake db:create?"
            puts "1 - yes, please"
            puts "2 - no, thanks"
            begin puts("Do it manually, if you wish."); exit; end if STDIN.gets != "1\n"
            puts ".."
            Rake::Task['db:create'].reenable
            Rake::Task['db:create'].invoke
            #system "rake #{name}"
            sleep UI_DELAY;puts ">> Database was created!";sleep UI_DELAY;
          rescue => e
            puts "Unable to invoke db:create. Check your database configuration."
            puts "Finished. Unable to setup Cms."
            exit
          end
        end
        sleep UI_DELAY;puts "OK";
      end

      #
      #  Invoke seed data
      #      
      
      unless text_exists?(OWNER_SEED_FILE_PATH, "Cms::Engine.load_seed")
        sleep UI_DELAY
        puts "Copy Cms migration scripts.."
        Rake::Task["cms:install:migrations"].reenable
        Rake::Task["cms:install:migrations"].invoke
        sleep UI_DELAY
        puts "Initialize Cms seed data.."
        inject_text(OWNER_SEED_FILE_PATH, -1, "Cms::Engine.load_seed")
        puts "Run all migrations.."
        Rake::Task["db:migrate"].reenable
        Rake::Task["db:migrate"].invoke
        sleep UI_DELAY
        puts "Load Cms seed data..."
        Rake::Task["db:seed"].reenable
        Rake::Task["db:seed"].invoke
        puts "Done!"
        sleep UI_DELAY
      end
      
      #
      # Add gem dependencies
      #
      
      puts "Add dependencies to Gemfile..";sleep UI_DELAY;
      major_gemfile_dependencies = [
        "gem 'haml' ",
        "gem 'codemirror-rails' ",
        "gem 'aloha-rails' "]
      minor_gemfile_dependencies = [
        "gem 'bootstrap-sass' " ]
      minor_gemfile_selections = [
        false
      ]
      gemfile_comment = "#=   CMS REQUIREMENTS END   =#"
      first_slash = "\n"
      major_gemfile_dependencies.each do |gem_file|
        sleep UI_DELAY;
        if text_exists?(OWNER_GEMFILE_PATH, gem_file)
          puts(gem_file + " already installed."); next;
        end
        puts(gem_file + " including..")
        inject_text(OWNER_GEMFILE_PATH, -1, first_slash + gem_file + "\n")
        first_slash = ''
      end
      puts "Including of minor dependencies (if you wish):"
      minor_gemfile_dependencies.each_with_index do |gem_file, index|

        next if text_exists?(OWNER_GEMFILE_PATH, gem_file)
        sleep UI_DELAY
        puts "Optional #{gem_file} wants to be included in Gemfile. Allow it?"
        puts "1 - yes, please"
        puts "2 - no, thanks"
        if STDIN.gets == "1\n"
          inject_text(OWNER_GEMFILE_PATH, -1, gem_file + "\n") 
          minor_gemfile_selections[index] = true
        end
      end
      inject_text(OWNER_GEMFILE_PATH, -1, gemfile_comment + "\n") unless text_exists?(OWNER_GEMFILE_PATH, gemfile_comment)
      
      #
      # Add javascript assets
      #
=begin
      puts "Add javascript assets to application.js..";sleep UI_DELAY;
      major_js_assets = [
        "//= require cms/application",
        "//= require codemirror",
        "//= require codemirror/modes/css"]
      minor_js_assets = [
        "//= require bootstrap" ]      
      major_js_assets.each do |js_asset|
        sleep UI_DELAY;
        if text_exists?(OWNER_APP_JS_PATH, js_asset)
          puts(js_asset + " already included."); next;
        end
        puts(js_asset + " including..");
        inject_text(OWNER_APP_JS_PATH, -1, js_asset+"\n")
      end
      puts "Minor dependencies including.."
      minor_js_assets.each_with_index do |js_asset, index|
        if minor_gemfile_selections[index] == true
          if text_exists?(OWNER_APP_JS_PATH, js_asset)
            puts(js_asset + " already included."); next;
          end
          puts(js_asset + " including..");
          inject_text(OWNER_APP_JS_PATH, -1, js_asset+"\n")
        end
      end
      
      #
      # Add css assets
      #
      
      puts "Add css assets to application.css..";sleep UI_DELAY;
      major_css_assets = [
        "require codemirror",
        "require aloha",
        "require cms/application"]
      minor_css_assets = [
        "require bootstrap" ]
      minor_css_assets_with_prompt = [
        "require bootstrap-responsive" ]
      css_prompts = [
        "bootstrap-responsive style" ]
      puts "Minor dependencies including.."
      minor_css_assets_with_prompt.each_with_index do |css_asset, index|
        if minor_gemfile_selections[index] == true
          if text_exists?(OWNER_APP_CSS_PATH, css_asset)
            puts "Are you wish #{css_prompts[index]} to be included?"
            puts "1 - yes, please"
            puts "2 - no, thanks"
            if STDIN.gets == "1\n"
              inject_text(OWNER_APP_CSS_PATH, 2, "*= " + css_asset + "\n")
            end
          end
        end
      end
      minor_css_assets.each_with_index do |css_asset, index|
        if minor_gemfile_selections[index] == true
          if text_exists?(OWNER_APP_CSS_PATH, css_asset)
            puts(css_asset + " already included."); next;
          end
          puts(css_asset + " including..");
          inject_text(OWNER_APP_CSS_PATH, 2,  "*= " + css_asset + "\n")
        end
      end
      major_css_assets.each do |css_asset|
        sleep UI_DELAY;
        if text_exists?(OWNER_APP_CSS_PATH, css_asset)
          puts(css_asset + " already included."); next;
        end
        puts(css_asset + " including..");
        inject_text(OWNER_APP_CSS_PATH, 2,  "*= " + css_asset + "\n")
      end
=end
      #
      #  Add Cms routes
      #
      
      route_line = "\n\n  # This is a Cms route line. Add your custom routes above this line.\n    mount Cms::Engine, :at => '/'\n"
      route_finder = "Cms::Engine"
      unless text_exists?(OWNER_ROUTE_FILE_PATH, route_finder)
        sleep UI_DELAY; puts("Add CMS routes to routes.rb..")
        inject_text(OWNER_ROUTE_FILE_PATH, 2, route_line)
      end
      
      #
      #  Footer =)
      #
      
      puts "+++"
      puts "Finished Successfully!"
      puts "It is time to start your rails server: (rails s)."
      puts "Then, open your admin panel at 'http://localhost:3000/in'"
      puts "Default username/password are: admin/admin"
      puts "All rights reserved, InterLink (c) 2000-2013"
    end
    
    #  Inject text into specified line of file.
    #  If line_number is -1, text will be appended to the end of file.
    def inject_text(file_path, line_number, text)
      if line_number == -1
        open(file_path, 'a') do |f|
          f << text
        end
      else
        open(file_path, 'r+') do |f|
          while (line_number-=1) > 0
            f.readline
          end
          pos = f.pos
          rest = f.read
          f.seek pos
          f.write text
          f.write rest
        end
      end
    end
  
    def text_exists?(file_path, text)
      return File.readlines(file_path).grep(/#{text}/).size > 0
    end
    
    
    # TODO: Finish with autotests!!
    task :autotest do
      require File.expand_path("../../../config/environment", __FILE__)
      require 'rspec/rails'
      # Configure Rails Envinronment
      ENV["RAILS_ENV"] = "test"
      ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
      Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

      RSpec.configure do |config|
        config.use_transactional_fixtures = true
      end

      Rake::Task['db:load_config'].invoke
      puts ActiveRecord::Base.configurations['test'].inspect

      puts "hello!"
      params = %w(--quiet)
      params << "--database=#{ENV['DB']}" if ENV['DB']
      Rake::Task['spec'].invoke
    end

end
