#######################################################
# BitReaper
# Automated Web-Scraping Client for Ruby
#
# (c)2020 Yanis Zafirópulos 
#         aka Dr.Kameleon
#
#         <yaniszaf@gmail.com>
#######################################################
# @file lib/bitreaper.rb
#######################################################

require 'awesome_print'
require 'colorize'
require 'json'
require 'liquid'
require 'nokogiri'
require 'open-uri'
require 'sdl4r'

require_relative 'bitreaper/helpers.rb'

$bitreaper_version = "0.1.5"

##
# This is the main Web Scraper object. It is through a `BitScraper` instance
# that you can start scraping

class BitReaper

	##
	# Create a new BitReaper instance
	#
	# @param [String] url The URL of the page to be scraped
	# @param [String,SDL4R::Tag] parser The parser
	# @param [Integer] i Index of the current operation (for reporting purposes)

	def initialize(url,parser,i=0)
		@url = url
		@parser = (parser.is_a? String) ? self.getParser(parser) : parser

		@index = i
		@store = {}

		@noko = self.download(@url)
	end

	##
	# Get a new parser from a given parser path
	#
	# @param [String] file The path of the `.br` parser file
	#
	# @return [SDL4R::Tag] The resulting parser

	def self.getParser(file)
		parserFile = File.read(file)
		parserFile = parserFile.gsub(/([\w]+)\!/,'\1=on')
		if $verbose
			puts parserFile.split("\n").map{|l| "   "+l}.join("\n").light_black
			puts ""
		end

		return SDL4R::read(parserFile)
	end

	##
	# Download given URL
	#
	# @param [String] url The URL to be downloaded
	#
	# @return [Nokogiri::XML::NodeSet] The resulting nodes

	def download(url,withProgress=true)
		printProgress(@url,@index,0) if withProgress

		html = Nokogiri::HTML(open(url))

		return html
	end

	##
	# Process String value using attribute
	#
	# @param [String] attrb The attribute to be processed
	# @param [String] val The value to processed
	# @param [String] param The attribute's param (if any)
	#
	# @return [String,Array] The result of the operation

	def processStringValue(attrb,val,param)
		case attrb
			when "prepend"
				val = param + val
			when "append"
				val = val + param
			when "capitalize"
				val = val.capitalize
			when "uppercase"
				val = val.upcase
			when "lowercase"
				val = val.downcase
			when "trim"
				val = val.strip
			when "replace"
				val = val.gsub(param[0], param[1])
			when "remove"
				val = val.gsub(param,"")
			when "split"
				val = val.split(param)
			when "download"
				val = val
				val.downloadAs($outputDest,(param.is_a? String) ? param : nil)
			when "exclude"
				val = false
		end
		return val
	end

	##
	# Process Array value using attribute
	#
	# @param [String] attrb The attribute to be processed
	# @param [Array] val The value to processed
	# @param [String] param The attribute's param (if any)
	#
	# @return [String,Array] The result of the operation

	def processArrayValue(attrb,val,param)
		case attrb
			when "join"
				val = val.join(param)
			when "first"
				val = param==true ? val.first : val.first(param)
			when "last"
				val = param==true ? val.last : val.last(param)
			when "index"
				val = val[param.to_i]
			when "select.include"
				if param.start_with? "/"
					val = val.select{|r| r=~Regexp.new(param.tr('/', '')) }
				else
					val = val.select{|r| r.include? param }
				end
			when "select.match"
				if param.start_with? "/"
					val = val.select{|r| r=~Regexp.new("\A#{param.tr('/','')}\Z") }
				else
					val = val.select{|r| r==param }
				end
			when "exclude"
				val = false
		end
		return val
	end

	##
	# Process Hash value using attribute
	#
	# @param [String] attrb The attribute to be processed
	# @param [Array] val The value to processed
	# @param [String] param The attribute's param (if any)
	#
	# @return [String,Array] The result of the operation

	def processHashValue(attrb,val,param)
		case attrb
			when "list"
				val = squish(val)
				# toret = []
				# list = val.first[1]
				# list.each_with_index{|l,i|
				# 	dict = {}
				# 	val.keys.each{|key|
				# 		if val[key].is_a? Array 
				# 			if i<val[key].count
				# 				dict[key] = val[key][i]
				# 			end
				# 		end
				# 	}
				# 	toret << dict
				# }
				# val = toret
		end
	end

	##
	# Process parsed values using set of attributes
	#
	# @param [Array] values The parsed values
	# @param [Array] attrbs The associated attributes
	#
	# @return [String,Array] The result of the operation

	def processValues(values,attrbs)
		# check if we have a single value or an array of values
		if values.is_a? Nokogiri::XML::NodeSet
			# it is a nodeset, so let's extract the .content property
			ret = (values.count==1) ? values[0].content
									: values.map{|v| v.content}
		else
			# not a nodeset (perhaps a hash of values?)
			ret = values
		end

		# no attributes, just return it
		return ret if attrbs.size==0

		attrbs.each{|attrb,arg|
			if arg.is_a? String
				# get params if we have multiple params; or not
				param = (arg.include? "||") ? (arg.split("||").map{|a| Liquid::Template.parse(a).render(@store) }) 
											: Liquid::Template.parse(arg).render(@store)
			else 
				param = arg
			end

			if ret.is_a? String
				# if our value is a String, process it accordingly
				ret = self.processStringValue(attrb,ret,param)
			elsif ret.is_a? Array
				# it's an array of values, so look for array-operating attributes
				ret = self.processArrayValue(attrb,ret,param)
			elsif ret.is_a? Hash	
				# it's a value hash, so process it accordingly
				ret = self.processHashValue(attrb,ret,param)
			else 
				## Wtf is that?		
			end
		}

		return (ret.nil?) ? "" : ret
	end

	##
	# Process a given node using provided parser and temporary storage hash
	#
	# @param [Nokogiri::XML::node] noko The Nokogiri node to work on
	# @param [SDL4R::Tag] node The parser node
	# @param [Hash] store The temporary storage hash
	# @param [Integer] level The nesting level (for informational purposes)

	def processNode(noko,node,store,level=0)
		node.children.each{|child|
			command = child.namespace
			tag = child.name
			pattern = child.values[0] #Liquid::Template.parse(child.values[0]).render(@store)
			attrs = child.attributes

			if not command==""
				case command
					when "do"
						case tag
							when "fetch"
							gotoUrl = Liquid::Template.parse(pattern).render(@store)
							br = BitReaper.new(gotoUrl,child)
							store.merge! br.process()
						end
					when "define"
						@store[tag] = pattern
				end
			else
				if child.children.count==0
					# no children, so it's a "get"
					values = noko.search(pattern)

					if values.count>0
						processed = self.processValues(values,attrs)
						if processed!=false
							store[tag] = processed
						end
					end
				else
					# it's a "section"
					store[tag] = {}

					if pattern.nil?
						subnoko = noko
					else
						subnoko = noko.search(pattern)
					end

					processNode(subnoko,child,store[tag],level+1)
					store[tag] = self.processValues(store[tag],attrs)
				end
			end
		}
	end

	##
	# Process current project

	def process
		printProgress(@url,@index,1)
		processNode(@noko, @parser, @store)

		printProgress(@url,@index,2)
		return @store
	end

end

#######################################################
#
# This is the end;
# my only friend, the end...
#
#######################################################