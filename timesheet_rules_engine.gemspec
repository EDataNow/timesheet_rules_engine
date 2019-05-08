Gem::Specification.new do |s|
  s.name        = 'timesheet_rules_engine'
  s.version     = '0.0.2'
  s.date        = '2019-04-28'
  s.summary     = "Timesheet Rules Engine"
  s.description = "Timesheet Rules Engine"
  s.authors     = ["Shawn Lee-Kwong"]
  s.email       = 'slk@edatanow.com'
  s.files       = Dir["{lib}/**/*"]
  s.homepage    =
    'http://rubygems.org/gems/timesheet_rules_engine'
  s.license       = 'MIT'
  s.test_files = Dir["spec/**/*"]
  s.add_dependency "holidays"
  s.add_dependency "activesupport"
end