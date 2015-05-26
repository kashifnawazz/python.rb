Feature: programmer calculate numerical expression

  The programmer calculates numerical expressions through REPL console.
  REPL console print caluculated number in one line.

  Scenario Outline: calculate numerical expression
    Given I started repl but didn't input anything
    When I input "<expression>"
    Then the output expect be "<evaluated>"

    Scenarios: without operator
      | expression | evaluated |
      |          1 |         1 |
      |          0 |         0 |
      |         -1 |        -1 |

    Scenarios: single operator
      | expression | evaluated |
      |      1 + 2 |         3 |
      |      1 - 2 |        -1 |
      |      1 * 2 |         2 |
      |     1 // 2 |         0 |

    Scenarios: without space between tokens
      | expression | evaluated |
      |        1+2 |         3 |
      |    100+100 |       200 |

    Scenarios: double operator
      |  expression  | evaluated |
      |    1 + 2 + 3 |         6 |
      |    1 - 2 - 3 |        -4 |
      |    1 * 2 * 3 |         6 |
      |  9 // 3 // 2 |         1 |

    Scenarios: priority
      |   expression   | evaluated |
      |      1 + 2 * 3 |         7 |
      |      1 - 2 * 3 |        -5 |
      |     1 + 6 // 3 |         3 |
      |     1 - 6 // 3 |        -1 |

    Scenarios: parentheses
      |     expression     | evaluated |
      |                (1) |         1 |
      |               (-1) |        -1 |
      |  (1 + 2) * (3 + 4) |        21 |
      |      (1 - (2 - 3)) |         2 |
      |      ((1 + 2) * 3) |         9 |
