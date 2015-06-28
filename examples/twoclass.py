class Y:
    def __init__(self, val):
        self.val = val

class X:
    def __init__(self, val):
        self.y = Y(val)

print(X(1).y.val)
