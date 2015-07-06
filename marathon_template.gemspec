# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
spec.name          = "marathon-template"
spec.version       = '0.0.2'
spec.authors       = ["Jeff Malnick"]
spec.email         = ["malnick@gmail.com"]
spec.summary       = %q{Create dynamic haproxy configs from marathon resources}
spec.license       = "MIT"
spec.executables   << 'marathon-template'
spec.files         = ['ext/haproxy_example.yaml', 'lib/marathon_template.rb', "lib/marathon-template/deploy.rb", "lib/marathon-template/cron.rb", "lib/marathon-template/options.rb"]
spec.require_paths = ["lib"]
end
