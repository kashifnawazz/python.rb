Feature: programmer use advanced calculator

  The programmer calculates numerical expressions with conditions through REPL console.
  REPL console print caluculated number in one line.

  Scenario Outline: calculate numerical expression with conditions
    Given I started repl but didn't input anything
    When I input "<statement>"
    Then the output expect be "<evaluated>"

    Scenarios: with conditional operator
      | statement | evaluated |
      |     1 < 2 |      True |
      | 1 < 2 < 3 |      True |
      |     2 < 1 |     False |
      |    1 == 1 |      True |
      |    1 == 2 |     False |
      |     2 > 1 |      True |

    Scenarios: with not, and, or
      | statement | evaluated |
      |     not 1 |     False |
      |     not 0 |      True |
      |  not True |     False |
      | not False |      True |
      |   1 and 2 |         2 |
      |   1 and 0 |         0 |
      |    1 or 0 |         1 |
      |    0 or 1 |         1 |
      |    1 or 2 |         1 |

    Scenarios: with conditional expression
      |          statement          | evaluated |
      |  1 + 1 if 1 == 2 else 2 + 2 |         4 |
      |  1 + 1 if 1 == 1 else 2 + 2 |         2 |
