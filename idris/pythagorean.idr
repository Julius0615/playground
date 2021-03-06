
pythagorean : Int -> List (Int, Int, Int)
pythagorean n = [(x, y, z) | z <- [1..n], y <- [1..z], x <- [1..y], x*x + y*y == z*z]
