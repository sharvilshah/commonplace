require File.join(File.dirname(__FILE__), 'commonplace')
require 'rubygems'
require 'sinatra'
require 'erb'
require 'yaml'


class CommonplaceServer < Sinatra::Base	       
  
  configure do 
    	use Rack::Session::Cookie, {
      		:http_only => true,
      		:secret => ENV['SESSION_SECRET'] || SecureRandom.hex
    	}  
    	
    	set :github_options, {
        	:scopes    => "user",
        	:secret    => ENV['GITHUB_CLIENT_SECRET'],
        	:client_id => ENV['GITHUB_CLIENT_ID'],
    	}
		
		config = YAML::load(File.open("config/commonplace.yml"))
		set :sitename, config['sitename']
		set :dir, config['wikidir']
		set :readonly, config['readonly']
   		set :public_folder, "public"
   		set :views, "views"
	end
  
  	register Sinatra::Auth::Github

	before do
    	@wiki = Commonplace.new(settings.dir)
	end

	# if we've locked editing access on the config file, 
	# every method that edits, saves redirects to root
	# maybe this could be more elegant?
	before '/p/*' do 
		redirect "/" if settings.readonly
	end
	
	# show the homepage
	get '/' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
    	show('home')
	end
	
	# show the known page list
	get '/list' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
		@name = "Known pages"
		@pages = @wiki.list
		erb :list
	end

	# show everything else
	get '/:page' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
		show(params[:page])
	end
	
	# show everything else
	get '/:page/raw' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
		@page = @wiki.page(params[:page])
		@page.raw.to_s
	end
	
	# edit a given page
	get	'/p/:page/edit' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
		@page = @wiki.page(params[:page])
		
		if @page
			@name = "Editing " + @page.name
			@editing = true
			erb :edit
		else
			status 404
			@name = "404: Page not found"
			erb :error404
		end
	end
	
	# accept updates to a page
	post '/p/:page/edit' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
		page = @wiki.save(params[:page], params[:content])
		redirect "/#{page.permalink}"
	end

	# create a new page
	get '/p/new/?' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
		@name = "New page"
		@editing = true
		erb :new
	end
	
	# create a new page
	get '/p/new/:pagename' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
		@newpagename = @wiki.get_pagename(params[:pagename])
		@name = "Creating #{@newpagename}"
		@editing = true
		erb :new
	end
  
	
	# save the new page
	post '/p/save' do
    	github_organization_authenticate!(ENV['GITHUB_ORG_ID'])
		if params[:filename] && params[:filename] != ""
			filename = params[:filename].gsub(" ", "_").downcase
			page = @wiki.save(filename, params[:content])
			redirect "/#{page.permalink}"
		else
			@alert = "You're missing something important - a page name. Please add that."
			@name = "New page"
			@content = params[:content]
			erb :new
		end
	end

	# returns a given page (or file) inside our repository
	def show(name)
		if !@wiki.valid?
			status 500
			@name = "Wiki directory not found"
			@error = "We couldn't find the wiki directory your configuration is pointing to.<br/>Fix that, then come back - we'll be happier then."
			erb :error500
		else
			if @page = @wiki.page(name)
				# may success come to those who enter here.
				@name = @page.name
				@content = @page.content
				@tags = @page.tags
				erb :show
			else
				status 404
				@newpage = name
				@name = "404: Page not found"
				erb :error404
			end
		end
	end
end