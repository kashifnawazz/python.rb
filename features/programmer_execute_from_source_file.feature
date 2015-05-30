Feature: programmer execute python program in source file

  Scenario: execute script file
    Given in silence, I am on shell
    When I start interpreter with argument "number_of_the_beast.py":
      """
      six = 6
      print(six * 100 + six * 10 + six)
      """
    Then the output expect be "666"
