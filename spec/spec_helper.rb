$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require "rubygems"
require "spec"

Spec::Runner.configure do |config|
  def fixture(name)
    File.join(".", "spec", "fixtures", "#{name}.rb")
  end
end