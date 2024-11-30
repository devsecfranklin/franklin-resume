# importing numpy
import numpy as np

"""
Basic Arithmetic operation:
In this example we will see do arithmetic operations which are element-wise between two vectors of equal length to result in a new vector with the same length
"""

# creating a 1-D list (Horizontal)
list1 = [5, 6, 9]

# creating a 1-D list (Horizontal)
list2 = [1, 2, 3]

# creating first vector
vector1 = np.array([5, 6, 9])

# printing vector1
print("First Vector          : " + str(vector1))

# creating secodn vector
vector2 = np.array([1, 2, 3])

# printing vector2
print("Second Vector         : " + str(vector2))

# adding both the vector
# a + b = (a1 + b1, a2 + b2, a3 + b3)
addition = vector1 + vector2

# printing addition vector
print("Vector Addition       : " + str(addition))

# subtracting both the vector
# a - b = (a1 - b1, a2 - b2, a3 - b3)
subtraction = vector1 - vector2

# printing addition vector
print("Vector Substraction   : " + str(subtraction))

# multiplying  both the vector
# a * b = (a1 * b1, a2 * b2, a3 * b3)
multiplication = vector1 * vector2

# printing multiplication vector
print("Vector Multiplication : " + str(multiplication))

# dividing  both the vector
# a / b = (a1 / b1, a2 / b2, a3 / b3)
division = vector1 / vector2

# printing multiplication vector
print("Vector Division       : " + str(multiplication))
