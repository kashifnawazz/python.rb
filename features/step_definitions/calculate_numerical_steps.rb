class Out
  def messages
    @messages ||= []
  end

  def write(messge)
    print(message)
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
  @repl.read_eval_print(input)
end

Then(/^the output expect be "([^"]*)"$/) do |expected|
  if expected != ""
    expect(@out.messages.last).to eq(expected + "\n")
  else
    expect(@out.messages.last).to eq("")
  end
end

# Feature: programmer execute python program in source file
#-----

Given(/^in silence, I am on shell$/) do

end

When(/^I start interpreter with argument "([^"]*)":$/) do |filename, code|
  @interpreter = Python::FileInterpreter.new(code)
  original_stdout, $stdout = $stdout, Out.new
  @interpreter.execute
  $stdout, @out = original_stdout, $stdout
end
