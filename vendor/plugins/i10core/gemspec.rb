# Gem Specification
spec = Gem::Specification.new do |s|
  s.name = 'i10core'
  s.version = '0.1'
  s.summary = "i10 Core Gem"
  s.description = %{A collection of useful plugins for Ruby on Rails}
  s.files = Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options << '--title' <<  'i10 Core Gem'
  s.author = "Jonathan Diehl"
  s.email = "jonathan.diehl@rwth-aachen.de"
  s.homepage = "http://hci.rwth-aachen.de/gem"
  s.add_dependency 'rails', '>= 2.0.2'
  s.add_dependency 'fastercsv', '>= 1.2.3'
end