--
-- "Compute the average of an immutable single linked list (cons list) of integers. No variables."
-- See https://twitter.com/dibblego/status/130796120107532289
--

import Control.Arrow ((&&&), (***))
import Control.Category ((>>>))
import Data.List (genericLength)
import Data.Monoid (Sum(..), getSum)
import Data.Foldable (foldMap)

average :: Fractional n => [n] -> n
average = sum &&& genericLength >>> uncurry (/)

-- Using monoids.
average' :: Fractional n => [n] -> n
average' = foldMap (Sum &&& Sum . const 1) >>> getSum *** getSum >>> uncurry (/)

eg1 = average' $ map fromIntegral [1..5]
