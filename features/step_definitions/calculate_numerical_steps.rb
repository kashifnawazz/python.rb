class Out
  def messages
    @messages ||= []
  end

  def puts(message)
    print(message + "\n")
  end

  def print(message)
    messages << message
  end
end

# Feature: programmer starts REPL console
#-----

Given(/^I am not yet inputting anything$/) do
  @out = Out.new
  @repl = Python::REPL.new(@out)
end

When(/^I start a new REPL console$/) do
  @repl.start
end

Then(/^I expect see "([^"]*)"$/) do |message|
  expect(@out.messages).to eq([message])
end

# Feature: programmer calculate numerical expression
#-----

Given(/^I started repl but didn't input anything$/) do
  @out = Out.new
  @repl = Python::REPL.new(@out)
  @repl.start
end

When(/^I input "([^"]*)"$/) do |input|
  @input = input
end

Then(/^the output expect be "([^"]*)"$/) do |expected|
  @repl.read_eval_print(@input)
  expect(@out.messages.drop(1)).to include(expected + "\n")
end
