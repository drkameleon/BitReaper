Gem::Specification.new do |s|
  s.name        = 'bitreaper'
  s.version     = '0.1.0'
  s.date        = '2020-04-09'
  s.summary     = "BitReaper"
  s.description = "Automated Web-Scraping Client for Ruby"
  s.authors     = ["Dr.Kameleon"]
  s.email       = 'drkameleon@gmail.com'
  s.files       = [
    "bin/bitreaper",
    "lib/bitreaper.rb",
    "lib/bitreaper/helpers.rb"
  ]
  s.executables << "bitreaper"
  s.homepage    = 'https://rubygems.org/gems/bitreaper'
  s.license     = 'MIT'
end