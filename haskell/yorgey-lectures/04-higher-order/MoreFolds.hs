{-# LANGUAGE ScopedTypeVariables #-}

xor :: [Bool] -> Bool
xor = foldr f False
  where
    f True b = not b
    f False b = b

map_ :: (a -> b) -> [a] -> [b]
map_ f = foldr ((:) . f) []

data Exp
  = Op Exp Exp
  | Lit Integer
  deriving (Show, Eq)

r1 :: Integer
r1 = 4 - (2 - 1)
t1 :: Bool
t1 = foldr (-) 1 [4, 2] == r1
r2 :: Integer
r2 = (1 - 4) - 2
t2 :: Bool
t2 = foldl (-) 1 [4, 2] == r2

foldl_ :: (a -> b -> a) -> a -> [b] -> a
foldl_ _ a [] = a
foldl_ f a (b:bs) = foldl_ f (f a b) bs

foldLeft :: forall a b. (b -> a -> b) -> b -> [a] -> b
foldLeft f i as = foldr ff id as i
  where
    ff :: a -> (b -> t) -> (b -> t)
    ff a bf = bf . (`f` a)

-- foldr :: (a -> b -> b) -> b -> [a] -> b
-- foldl :: (b -> a -> b) -> b -> [a] -> b

rev :: [a] -> [a]
rev = foldLeft (flip (:)) []

fr :: Integer -> Exp -> Exp
fr n e = Op (Lit n) e

fl :: Exp -> Integer -> Exp
fl = flip fr

fr1 :: Exp
fr1 = 4 `fr` (2 `fr` (Lit 1))

fl1 :: Exp
fl1 = ((Lit 1) `fl` 4) `fl` 2

left :: Exp -> Integer -> Exp
left e n = Op e (Lit n)

want1 :: Exp
want1 = (Lit 1 `Op` Lit 4) `Op` Lit 2

want2 :: Exp
want2 = (Lit 1 `left` 4) `left` 2

want3 :: Exp
want3 = foldl_   left (Lit 1) [4, 2]

want4 :: Exp
want4 = foldLeft left (Lit 1) [4, 2]

tests :: [Bool]
tests = [want1 == want2, want2 == want3, want3 == want4]
