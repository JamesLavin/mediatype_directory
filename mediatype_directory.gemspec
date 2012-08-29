$:.push File.expand_path("../lib", __FILE__)
require 'mediatype_directory/version'

Gem::Specification.new do |s|
  s.name            = 'mediatype_directory'
  s.version         = MediatypeDirectory::VERSION
  s.platform        = Gem::Platform::RUBY
  s.authors         = ['James Lavin']
  s.email           = ['mediatype_directory@futureresearch.com']
  s.homepage        = "https://github.com/JamesLavin/mediatype_directory"
  s.summary         = %q{Creates directory of links for all files with specified mediatype in subdirectory tree}
  s.description     = %q{Creates directory of hard or soft links for all files with specified mediatype (.pdf, .mp4, etc.) in subdirectory tree}
  #s.add_runtime_dependency = ['fileutils','pathname']
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fakefs'
  s.require_paths   = ['lib']
  s.files           = `git ls-files`.split("\n")
  s.test_files      = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables     = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
