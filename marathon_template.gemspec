Gem::Specification.new do |s|
  s.name        = 'marathon_template'
  s.version     = '0.0.1'
  s.date        = '2015-07-05'
  s.summary     = "Dynamic haproxy via Marathon"
  s.description = "Builds HaProxy cfg file from /etc/haproxy.yaml"
  s.authors     = ["Jeff Malnick"]
  s.email       = 'malnick@gmail.com'
  s.files       = ["lib/marathon_template.rb"]
  s.homepage    =
    'http://rubygems.org/gems/marathon_template'
  s.license     = 'MIT'
  s.executables << 'marathon_template'
end
