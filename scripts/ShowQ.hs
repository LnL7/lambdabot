--
-- Helper code for runplugs
--
-- Note: must be kept in separate module to hide unsafePerformIO from
-- runplugs-generated eval code!! you're warned.
--
module ShowQ where

import Language.Haskell.TH
import System.IO.Unsafe
import Data.Dynamic

import Test.QuickCheck.Batch
import Test.QuickCheck
import Data.Char
import Data.List
import Data.Word
import Data.Int
import System.Random

instance (Typeable a, Typeable b) => Show (a -> b) where
    show e = '<' : (show . typeOf) e ++ ">"

instance Ppr a => Show (Q a) where
    show e = unsafePerformIO $ runQ e >>= return . pprint

instance Arbitrary Char where
    arbitrary     = choose ('a', 'z')
    coarbitrary c = variant (ord c `rem` 4)

instance Arbitrary Word8 where
    arbitrary = choose (minBound, maxBound)
    coarbitrary c = variant (fromIntegral ((fromIntegral c) `rem` 4))

instance Arbitrary Ordering where
    arbitrary     = elements [LT,EQ,GT]
    coarbitrary LT = variant 1
    coarbitrary EQ = variant 2
    coarbitrary GT = variant 0

instance Arbitrary Int64 where
  arbitrary     = sized $ \n -> choose (-fromIntegral n,fromIntegral n)
  coarbitrary n = variant (fromIntegral (if n >= 0 then 2*n else 2*(-n) + 1))

instance Arbitrary a => Arbitrary (Maybe a) where
  arbitrary           = do a <- arbitrary ; elements [Nothing, Just a]
  coarbitrary Nothing = variant 0
  coarbitrary _       = variant 1 -- ok?

instance Random Word8 where
  randomR = integralRandomR
  random = randomR (minBound,maxBound)

instance Random Int64 where
  randomR = integralRandomR
  random  = randomR (minBound,maxBound)

integralRandomR :: (Integral a, RandomGen g) => (a,a) -> g -> (a,g)
integralRandomR  (a,b) g = case randomR (fromIntegral a :: Integer,
                                         fromIntegral b :: Integer) g of
                            (x,g) -> (fromIntegral x, g)

myquickcheck :: Testable a => a -> IO String
myquickcheck a = do
    rnd <- newStdGen
    tests (evaluate a) rnd 0 0 []

tests :: Gen Result -> StdGen -> Int -> Int -> [[String]] -> IO String
tests gen rnd0 ntest nfail stamps
  | ntest == 100  = done "OK, passed" ntest stamps
  | nfail == 1000 = done "Arguments exhausted after" ntest stamps
  | otherwise = case ok result of
       Nothing    -> tests gen rnd1 ntest (nfail+1) stamps
       Just True  -> tests gen rnd1 (ntest+1) nfail (stamp result:stamps)
       Just False -> return $ "Falsifiable, after "
                               ++ show ntest
                               ++ " tests:\n"
                               ++ unlines (arguments result)
   where
      result      = generate (((+ 3) . (`div` 2)) ntest) rnd2 gen
      (rnd1,rnd2) = split rnd0

done :: String -> Int -> [[String]] -> IO String
done mesg ntest stamps = return $ mesg ++ " " ++ show ntest ++ " tests" ++ table
 where
  table = display
        . map entry
        . reverse
        . sort
        . map pairLength
        . group
        . sort
        . filter (not . null)
        $ stamps

  display []  = ".\n"
  display [x] = " (" ++ x ++ ").\n"
  display xs  = ".\n" ++ unlines (map (++ ".") xs)

  pairLength xss@(xs:_) = (length xss, xs)
  entry (n, xs)         = percentage n ntest
                       ++ " "
                       ++ concat (intersperse ", " xs)

  percentage n m        = show ((100 * n) `div` m) ++ "%"
