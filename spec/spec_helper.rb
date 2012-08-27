require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
end

Dir["./spec/support/**/*.rb"].each {|f| require f}
