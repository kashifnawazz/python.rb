class A:
    def __init__(self, x):
        self.x = x
        
    def add(self, d):
        self.x = self.x + d
        return self

a = A(1).add(2).add(3)
print(a.x)
