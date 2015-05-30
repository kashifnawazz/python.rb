def fib(n):
    cond = n == 0 or n == 1
    return n if cond else fib(n - 1) + fib(n - 2)

print(fib(10))
