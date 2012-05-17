Gem::Specification.new do |s|
  s.name        = "uuvula"
  s.version     = "0.0.2"
  s.date        = "2012-05-17"
  s.summary     = "Hola!"
  s.description = "A better way to do UUID in Rails 2/3"
  s.authors     = ["Alexander Rakoczy"]
  s.email       = "arakoczy@gmail.com"
  s.files       = ["lib/uuvula.rb"]
  s.homepage    = "https://github.com/thumblemonks/uuvula"
  s.add_dependency('uuidtools', '~>2.1.2')
  s.add_dependency('rails', '~>2.3.2')
end
