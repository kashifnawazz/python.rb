Feature: programmer use class

  Scenario: define simple class and make instance
    Given in silence, I am on shell
    When I start interpreter with argument "defineclass.py":
      """
      class A:
        def mymethod(self, x):
          return x

      a = A()
      print(a.mymethod(2))
      """
    Then the output expect be "2"

  Scenario: define class having static variable and use it
    Given in silence, I am on shell
    When I start interpreter with argument "staticclassvariable.py":
      """
      class B:
        staticvar = 123

      b = B()
      print(b.staticvar)
      """
    Then the output expect be "123"

    Scenario: define two class
      Given in silence, I am on shell
      When I start interpreter with argument "class2.py":
        """
        class Y:
          def __init__(self, val):
            self.val = val

        class X:
          def __init__(self, val):
            self.y = Y(val)

        print(X(1).y.val)
        """
      Then the output expect be "1"
