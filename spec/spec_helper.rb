$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require "rubygems"
require "spec"

Spec::Runner.configure do |config|
  def fixture(name)
    filename = name.is_a?(Symbol) ? "#{name}.rb" : name
    File.join(".", "spec", "fixtures", filename)
  end
end