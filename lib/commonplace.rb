require 'rubygems'
require 'redcarpet'
require 'pygments'

class Commonplace
  
	attr_accessor :dir
	
	# initialize our wiki class
	def initialize(dir)
		@dir = dir
	end
	
	# checks if our directory exists
	def valid?
		File.directory? dir
	end
	
	# returns a raw list of files in our wiki directory, sans . and ..
	def files
		# if the directory doesn't exist, we bail out with a nil
		return nil unless File.directory? dir
		
		f = Dir.entries(dir)
		f.delete(".")
		f.delete("..")
    f.delete(".DS_Store")

		return f
	end
		
	# returns an array of known pages
	def list
		files.map! { |filename|
			{:title => file_to_pagename(filename), :link => filename.chomp(".md")}
		}
	end
	
	# converts a pagename into the permalink form
	def get_permalink(pagename)
		pagename.gsub(" ", "_").downcase
	end
	
	# converts a permalink to the full page name
	def get_pagename(permalink)
		permalink.gsub('_', ' ').capitalize
	end
	
	# converts a pagename into the full filename
	def get_filename(pagename)
		get_permalink(pagename) + ".md"
	end
	
	# converts a filename into a page title
	def file_to_pagename(filename)
		filename.chomp(".md").gsub('_', ' ').capitalize
	end
		
	# returns a page instance for a given filename
	def page(permalink)
		# check if the file exists, return nil if not
		file = dir + '/' + permalink + '.md'
		return nil unless File.exists? file # bail out if the file doesn't exist
		
		# check if we can read content, return nil if not
		content = File.new(file, :encoding => "UTF-8").read
		return nil if content.nil?
		
		# return a new Page instance
		return Page.new(content, permalink, self)
	end

	# create a new page and return it when done
	def save(filename, content)
		# FIXME - if the file exists, this should bail out
		
		# write the contents into the file
		file = dir + '/' + filename + '.md'
		f = File.new(file, "w")
		f.write(content)
		f.close
		
		# return the new file
		return page(filename)
	end
end

class SyntaxRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    if language && !language.empty?
      Pygments.highlight(code, lexer: language)
    else
      "<pre><code>#{code}</code></pre>"
    end
  end
  
  def header(title, level)
    @headers ||= []
    permalink = title.gsub(/\W+/, '-')

    if @headers.include? permalink
      permalink += '_1'
      permalink = permalink.succ while @headers.include? permalink
    end
    @headers << permalink
    %(
      <h#{level} id=\"#{permalink}\"><a name="#{permalink}" class="anchor" href="##{permalink}"></a>#{title}</h#{level}>
    )
  end
  
end


class Page
	attr_accessor :name, :permalink
	
	def initialize(content, filename, wiki)
		@content = content # the raw page content
		@permalink = filename
		@name = filename.gsub('_', ' ').capitalize
		@wiki = wiki
		@tags = tags #["hello", "world"]
	end
  
  	def optionize(options)
    	options.inject({}) { |memo, option| memo[option] = true; memo }
  	end
	
	# return html for markdown formatted page content
	def content    
    	renderer = SyntaxRenderer.new(optionize [
        	:with_toc_data,
        	#{:hard_wrap,
        	:xhtml,
        	:prettify
      	])
    
    	markdown = Redcarpet::Markdown.new(renderer, optionize([
        	:fenced_code_blocks,
        	:no_intra_emphasis,
        	:tables,
        	:superscript,
        	:autolink,
        	:strikethrough,
        	:space_after_headers,
        	:with_toc_data,
        	:quote,
        	:lax_spacing
      	]))
    
    	return markdown.render(parse_links(@content))  
	end

	def tags
	  return ["hello-there", "world tour"]
  end
	
  
	# return raw page content
	def raw
		return @content
	end
	
	# looks for links in a page's content and changes them into anchor tags
	def parse_links(content)
		return content.gsub(/\[\[(.+?)\]\]/m) do
			name = $1
			permalink = name.downcase.gsub(' ', '_')
      
			if @wiki.page(permalink)
				"<a class=\"internal\" href=\"/#{permalink}\">" + name + '</a>'
			else 
				"<a class=\"internal new\" href=\"/#{permalink}\">" + name + '</a>'
			end
		end.to_s
	end
end