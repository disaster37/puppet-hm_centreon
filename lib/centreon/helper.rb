require 'simplecov'
SimpleCov.start
SimpleCov.coverage_dir 'coverage'

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
