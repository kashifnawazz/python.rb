Feature: programmer starts REPL console

  As a programmer
  I want to start REPL console
  So that I can input and run python code

  Scenario: start REPL
    Given I am not yet inputting anything
    When I start a new REPL console
    Then I expect see "python.rb> "
