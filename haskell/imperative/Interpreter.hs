-- Interpreter for Imp, based on evaluation semantics
-- Developed for use in COMP3610
-- Clem Baker-Finch

module Interpreter where

import AbsSyn

-- A good match with the semantic definition would be to build the state
-- data structure as a function from Names to Ints:

{-
type State = Name -> Int

arid :: State
arid = \x -> error ("Unknown identifier: " ++ x)

update :: State -> Name -> Int -> State
update s x n = \y -> if x==y then n else s y
-}

-- But we want the interpreter to print out the state which is the result
-- of the interpretation so a "finite" data representation is more
-- appropriate.

-- State is a list of pairs (a graph of the function).  The update
-- operation scans the list for the argument so it is always an O(n)
-- operation.  It would probably be better (and a little easier) to just
-- stick it on the front of the list every time (i.e. a stack).  Straight
-- list manipulation is easier, but I want a new type which can be an
-- instance of Show.

newtype Env = Env [(Name, Int)]

apply :: Env -> Name -> Int

apply (Env fm) x =
    case lookup x fm of
    Just n  -> n
    Nothing -> error ("Undeclared identifier: " ++ show x)

update :: Env -> Name -> Int -> Env

update (Env fm) x n =
    Env (listUpdate fm x n)
	where listUpdate [] x n = [(x,n)]
	      listUpdate ((y,n'):ps) x n
		  | x==y        = ((x,n):ps)
		  | otherwise   = ((y,n'): listUpdate ps x n)

instance Show Env where
    show (Env bindings) = "environment = {\n" ++ concat middle ++ "}\n"
      where
        middle = map fred bindings
        fred (var, value) = "  " ++ var ++ " = " ++ (show value) ++ "\n"

initEnv :: Env
initEnv = Env []

-- Arithmetic expressions:

evalA :: Aexp -> Env -> Int

evalA (Num n) s      = n
evalA (Var x) s      = apply s x
evalA (a0 :+: a1) s  = n0 + n1
    where n0 = evalA a0 s
          n1 = evalA a1 s
evalA (a0 :-: a1) s  = n0 - n1
    where n0 = evalA a0 s
          n1 = evalA a1 s
evalA (a0 :*: a1) s  = n0 * n1
    where n0 = evalA a0 s
          n1 = evalA a1 s

-- Boolean expressions:

evalB :: Bexp -> Env -> Bool

evalB TrueLit s        = True
evalB FalseLit s       = False
evalB (a0 :=: a1) s    = n0 == n1
    where n0 = evalA a0 s
          n1 = evalA a1 s
evalB (a0 :<=: a1) s   = n0 <= n1
    where n0 = evalA a0 s
          n1 = evalA a1 s
evalB (Not b) s = not t
    where t = evalB b s
evalB (b0 `And` b1) s  = t0 && t1
    where t0 = evalB b0 s
          t1 = evalB b1 s
evalB (b0 `Or` b1) s   = t0 || t1
    where t0 = evalB b0 s
          t1 = evalB b1 s

-- Commands:

eval :: Com -> Env -> Env

eval (x := a) s     = update s x n
    where n = evalA a s
eval Skip s         = s
eval (c0 :~: c1) s  = s''
    where s'  = eval c0 s
          s'' = eval c1 s'
eval (If b c0 c1) s
    | t           = s0
    | otherwise   = s1
    where t  = evalB b s
          s0 = eval c0 s
          s1 = eval c1 s
eval (While b c) s
    | t           = s''
    | otherwise   = s
    where t   = evalB b s
	  s'  = eval c s
          s'' = eval (While b c) s'
