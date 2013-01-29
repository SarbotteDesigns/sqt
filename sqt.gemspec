Gem::Specification.new do |s|
  s.name        = 'sqt'
  s.version     = '1.0.2'
  s.date        = '2012-01-22'
  s.summary     = "Sarbotte Quality Tool"
  s.description = "Client side quality validator"
  s.authors     = ["Nicolas Barbotte"]
  s.email       = 'n.barbotte@gmail.com'
  s.files       = ["lib/sqt.rb"]
  s.homepage    = 'https://github.com/SarbotteDesigns/sqt'

  s.add_dependency('nokogiri', '~> 1.5.6')
  s.add_dependency('colorize', '~> 0.5.8')
  s.add_dependency('win32console', '~> 1.3.2')

  s.executables << 'sqt.rb'
end
