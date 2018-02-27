require File.expand_path('../lib/omniauth-github-organization/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Boris Ding', 'Michael Bleigh']
  gem.email         = %w[lding@sequoiacap.com michael@intridea.com]
  gem.description   = 'This is the OmniAuth strategy for authenticating to GitHub Organization.'
  gem.summary       = 'This is the OmniAuth strategy for authenticating to GitHub Organization.'
  gem.homepage      = 'https://github.com/sequoia-china/omniauth-github-organization'
  gem.license       = 'MIT'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'omniauth-github-organization'
  gem.require_paths = ['lib']
  gem.version       = OmniAuth::GitHubOrganization::VERSION

  gem.add_dependency 'omniauth', '~> 1.5'
  gem.add_dependency 'omniauth-oauth2', '>= 1.4.0', '< 2.0'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rspec', '~> 3.5'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'
end
