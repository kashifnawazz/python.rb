Feature: programmer use closure

  Scenario: calc fibonacci-number by using closure in script file
    Given in silence, I am on shell
    When I start interpreter with argument "fibonacci.py":
      """
      def fib(n):
        cond = n == 0 or n == 1
        return n if cond else fib(n - 1) + fib(n - 2)

      print(fib(10))
      """
    Then the output expect be "55"

  Scenario: play with a high-order function (a function returns a function) in script file
    Given in silence, I am on shell
    When I start interpreter with argument "highorder1.py":
      """
      def curried_add(a):
        def add(b):
          return a + b
        return add

      print(curried_add(1)(2))
      """
    Then the output expect be "3"

    Scenario: play with a high-order function (a function takes a function) in script file
      Given in silence, I am on shell
      When I start interpreter with argument "highorder2.py":
        """
        def twice(f, arg):
          return f(f(arg))

        def double(a):
          return a * 2

        print(twice(double, 5))
        """
      Then the output expect be "20"
