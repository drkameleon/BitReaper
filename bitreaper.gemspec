Gem::Specification.new do |s|
  s.name        = 'bitreaper'
  s.version     = '0.1.5'
  s.date        = '2020-04-13'
  s.summary     = "BitReaper"
  s.description = "Automated Web-Scraping Client for Ruby using SLD2-like configuration files. Supports XPath and CSS selectors via Nokogiri."
  s.authors     = ["Dr.Kameleon"]
  s.email       = 'drkameleon@gmail.com'
  s.files       = [
    "bin/bitreaper",
    "lib/bitreaper.rb",
    "lib/bitreaper/helpers.rb"
  ]
  s.executables << "bitreaper"

  s.add_runtime_dependency 'awesome_print'
  s.add_runtime_dependency 'colorize'
  s.add_runtime_dependency 'down'
  s.add_runtime_dependency 'fileutils'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'liquid'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'sdl4r'

  s.homepage    = 'https://github.com/drkameleon/BitReaper'
  s.license     = 'MIT'

end