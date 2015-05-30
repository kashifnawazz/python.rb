Feature: programmer use variables on REPL console

  Scenario: use variables
    Given I started repl but didn't input anything
    When I input "x = 1"
    Then the output expect be ""
    When I input "x"
    Then the output expect be "1"
    When I input "x = x + 1"
    Then the output expect be ""
    When I input "x"
    Then the output expect be "2"
