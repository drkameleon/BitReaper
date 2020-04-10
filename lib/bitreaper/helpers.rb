#######################################################
# BitReaper
# Automated Web-Scraping Client for Ruby
#
# (c)2020 Yanis Zafirópulos 
#         aka Dr.Kameleon
#
#         <yaniszaf@gmail.com>
#######################################################
# @file lib/bitreaper/helpers.rb
#######################################################

##########################################
# HELPER FUNCTIONS
##########################################

class String
	def ellipsisize(minimum_length=15,edge_length=15)
		return self if self.length < minimum_length or self.length <= edge_length*2 
		edge = '.'*edge_length    
		mid_length = self.length - edge_length*2
		gsub(/(#{edge}).{#{mid_length},}(#{edge})/, '\1...\2')
	end
end

def printLogo
	puts ("  ____  _ _   ____\n" +                           
		  " | __ )(_) |_|  _ \\ ___  __ _ _ __   ___ _ __\n" +
	 	  " |  _ \\| | __| |_) / _ \\/ _` | '_ \\ / _ \\ '__|\n" +
	 	  " | |_) | | |_|  _ <  __/ (_| | |_) |  __/ |\n" + 
	 	  " |____/|_|\\__|_| \\_\\___|\\__,_| .__/ \\___|_|\n").light_cyan.bold +
	 	 
	 	 " (c) 2020, Dr.Kameleon".cyan + "       |_| ".light_cyan.bold

	puts ""	
end

def showError(msg)
	puts " BitReaper v0.1.0\n".bold +
		 " (c)2020 Dr.Kameleon\n"
	puts "-" * 90
	print " ✘ ERROR: ".light_red.bold
	puts msg.split("\n").join("\n          ")
	puts "-" * 90
	puts ""
	exit
end

def showInfo(msg)
	puts " ● " + msg
end

def showSuccess(msg)
	puts (" ● " + msg).light_green.bold
	puts ""
end

def printProgress(item,indx,stage)
	case stage
		when 0
			msg = "Downloading..."
		when 1
			msg = "Processing... "
		when 2
			msg = "OK ✔︎          ".light_green.bold
			msg += "\n"
	end

	print "\r"
	print " ► [#{indx+1}/#{$total}] ".bold + item.ellipsisize.light_magenta.underline + " ➔ " + msg
end

def saveStoreToFile(file,store)
	puts ""
	showInfo("finished processing #{$total} entries")
	showInfo("saving to file: " + file)
	puts "\n"

	File.open(file,"w"){|f|
		f.write(JSON.pretty_generate(store))
	}

	showSuccess("SUCCESS :)")
end

#######################################################
#
# This is the end;
# my only friend, the end...
#
#######################################################