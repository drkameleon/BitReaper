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
require 'watir'
require 'webdrivers'

require_relative 'bitreaper/helpers.rb'

##########################################
# SUPERGLOBALS
##########################################

$bitreaper_version = 0.1

##########################################
# MAIN CLASS
##########################################

class BitReaper
	def initialize(url,parser,i=0)
		@url = url
		@parser = (parser.is_a? String) ? self.getParser(parser) : parser

		@index = i
		@store = {}

		@noko = self.download(@url)
	end

	def self.getParser(file)
		parserFile = File.read(file)
		parserFile = parserFile.gsub(/([\w]+)\!\s/,'\1=on')
		if true
			puts parserFile.split("\n").map{|l| "   "+l}.join("\n").light_black
			puts ""
		end

		return SDL4R::read(parserFile)
	end

	def download(url,withProgress=true)
		printProgress(@url,@index,0) if withProgress

		return Nokogiri::HTML(open(url))
	end

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
		end
		return val
	end

	def processArrayValue(attrb,val,param)
		case attrb
			when "join"
				val = val.join(param)
			when "first"
				val = val.first
			when "last"
				val = val.last
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
		end
		return val
	end

	def processValues(values,attrbs)
		# check if we have a single value or an array of values
		ret = (values.count==1) ? values[0].content
								: values.map{|v| v.content}

		# no attributes, just return it
		return ret if attrbs.size==0

		attrbs.each{|attrb,arg|
			if arg.is_a? String
				# get params if we have multiple params; or not
				param = (arg.include? "||") ? (arg.split("||").map{|a| Liquid::Template.parse(a).render(@store) }) 
											: Liquid::Template.parse(arg).render(@store)
			end

			if ret.is_a? String
				# if our value is a String, process it accordingly
				ret = self.processStringValue(attrb,ret,param)
			else
				# it's an array of values, so look for array-operating attributes
				ret = self.processArrayValue(attrb,ret,param)
				
			end
		}

		return (ret.nil?) ? "" : ret
	end

	def processNode(noko,node,store,level=0)
		node.children.each{|child|
			command = child.namespace
			tag = child.name
			pattern = child.values[0]
			attrs = child.attributes

			if child.children.count==0
				# no children, so it's a "get"
				values = noko.search(pattern)

				if values.count>0
					store[tag] = self.processValues(values, attrs)
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
			end
		}
	end

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