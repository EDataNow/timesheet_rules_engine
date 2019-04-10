require 'rspec'
require 'csv'
require 'stringio'
require 'active_support/all'

class String
  def demodulize(path=self)
    path = path.to_s
    if i = path.rindex("::")
      path[(i + 2)..-1]
    else
      path
    end
  end
end

class CustomFormatter
  RSpec::Core::Formatters.register self, :initialize, :example_group_started,
                                         :example_passed, :example_failed,
                                         :close

  def initialize(output)
    io = StringIO.new
    @output = output
    @all = []
    @passes = []
    @fails = []
  end

  def example_group_started(group_notification)
    @all << ["Group: #{group_notification.group.to_s.demodulize}"]

    @output << "group: " << group_notification.group.to_s.demodulize << "\n"
  end

  def example_passed(notification)
    result = [
      notification.example.description
    ]

    @all << result
    @passes << result
    @output << "example passed: " << notification.example.description << "\n"
  end

  def example_failed(notification)
    result = [
      notification.example.description
    ]

    @all << result
    @fails << result
    @output << "example failed: " << notification.example.description << "\n"
  end

  def close(notification)
    CSV.open("test.csv", "wb") do |csv|
      csv << ["Name"]

      @all.each {|a| csv << a }
    end
  end

  private
end