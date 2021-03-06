module Main where

import Data.Foldable
import Data.Int
import Data.Tuple
import Debug.Trace
import Effect (Effect)
import Effect.Console (logShow)
import Math
import Prelude

type Pos = {
    x :: Int,
    y :: Int,
    z :: Int
}

type Moon = {
    position :: Pos,
    velocity :: Pos
}

getX :: Moon -> Int
getX moon =
    moon.position.x

getY :: Moon -> Int
getY moon =
    moon.position.y

getZ :: Moon -> Int
getZ moon =
    moon.position.z

getVelX :: Moon -> Int
getVelX moon =
    moon.velocity.x

getVelY :: Moon -> Int
getVelY moon =
    moon.velocity.y

getVelZ :: Moon -> Int
getVelZ moon =
    moon.velocity.z

setVelX :: Int -> Moon -> Moon
setVelX x moon =
    moon { velocity { x = x } }

setVelY :: Int -> Moon -> Moon
setVelY y moon =
    moon { velocity { y = y } }

setVelZ :: Int -> Moon -> Moon
setVelZ z moon =
    moon { velocity { z = z } }

applyGravity :: Array Moon -> Moon -> Moon
applyGravity allMoons moon =
    moon
        # applyGravityOn allMoons getX getVelX setVelX
        # applyGravityOn allMoons getY getVelY setVelY
        # applyGravityOn allMoons getZ getVelZ setVelZ

applyGravityOn :: Array Moon -> (Moon -> Int) -> (Moon -> Int) -> (Int -> Moon -> Moon) -> Moon -> Moon
applyGravityOn allMoons getPosition getVelocity setVelocity moon =
    foldl
        (\accMoon otherMon ->
        let
            accPos =
                getPosition accMoon
            otherPos =
                getPosition otherMon
            accVel =
                getVelocity accMoon
            move =
                if otherPos > accPos then
                    1
                else if otherPos < accPos then
                    -1
                else
                    0
        in
        setVelocity (accVel + move) accMoon
    )
    moon
    allMoons

applyVelocity :: Moon -> Moon
applyVelocity moon =
    moon {
        position {
            x = moon.position.x + moon.velocity.x,
            y = moon.position.y + moon.velocity.y,
            z = moon.position.z + moon.velocity.z
        }
    }

applyGravities :: Array Moon -> Array Moon
applyGravities moons =
    moons # map (applyGravity moons)

applyVelocities :: Array Moon -> Array Moon
applyVelocities moons =
    moons # map applyVelocity

steps =
    1000

tick :: Int -> Array Moon -> Array Moon
tick iter moons =
    if iter >= steps then
        moons
    else
        let
            newMoons =
                moons
                    # applyGravities
                    # applyVelocities
        in
            newMoons
            # spy "newMoons"
            # tick (iter + 1)

tickUntilSame :: Array Moon -> (Array Moon -> Array Moon -> Boolean) -> Int -> Array Moon -> Tuple Int (Array Moon)
tickUntilSame initialState compare iter moons =
    if iter /= 0 && compare initialState moons then
        Tuple iter moons
    else
        let
            newMoons =
                moons
                    # applyGravities
                    # applyVelocities
        in
            newMoons
            # tickUntilSame initialState compare ((iter) + 1)

newMoon :: Int -> Int -> Int -> Moon
newMoon x y z =
    {
        position : {
            x : x,
            y : y,
            z : z
        },
        velocity : {
            x : 0,
            y : 0,
            z : 0
        }
    }

moonsExample1 :: Array Moon
moonsExample1 =
    [
        newMoon (-1) 0 2,
        newMoon 2 (-10) (-7),
        newMoon 4 (-8) 8,
        newMoon 3 5 (-1)
    ]

moonsExample2 :: Array Moon
moonsExample2 =
    [
        newMoon (-8) (-10) 0,
        newMoon 5 (5) (10),
        newMoon 2 (-7) 3,
        newMoon 9 (-8) (-3)
    ]

moonsInput :: Array Moon
moonsInput =
    [
        newMoon (-6) (-5) (-8),
        newMoon 0 (-3) (-13),
        newMoon (-15) (10) (-11),
        newMoon (-3) (-8) (3)
    ]

potentialEnergy :: Moon -> Number
potentialEnergy moon =
    abs (toNumber moon.position.x)
        + abs (toNumber  moon.position.y)
        + abs (toNumber moon.position.z)

kineticEnery moon =
    abs (toNumber moon.velocity.x) 
        + abs (toNumber  moon.velocity.y) 
        + abs (toNumber moon.velocity.z)

totalEnergyForMoon moon =
    potentialEnergy moon * kineticEnery moon

totalEnergy moons =
    moons
        # map totalEnergyForMoon
        # foldl (+) 0.0

-- run :: Number
-- run =
--     moonsExample1 # tick 0 # totalEnergy

comparePosX :: Array Moon -> Array Moon -> Boolean
comparePosX a b =
    map getX a == map getX b

comparePosY :: Array Moon -> Array Moon -> Boolean
comparePosY a b =
    map getY a == map getY b

comparePosZ :: Array Moon -> Array Moon -> Boolean
comparePosZ a b =
    map getZ a == map getZ b

compareVelX :: Array Moon -> Array Moon -> Boolean
compareVelX a b =
    map getVelX a == map getVelX b

compareVelY :: Array Moon -> Array Moon -> Boolean
compareVelY a b =
    map getVelY a == map getVelY b

compareVelZ :: Array Moon -> Array Moon -> Boolean
compareVelZ a b =
    map getVelZ a == map getVelZ b

gcd :: Number -> Number -> Number
gcd a b =
    if a == 0.0 then
        b
    else
        gcd (b % a) a

lcm :: Number -> Number -> Number
lcm a b =
     (a * b) / gcd a b

run2 :: Number
run2 =
    let
        moons =
            moonsExample1
        Tuple iterPosX _ =
            moons # tickUntilSame moons comparePosX 0
        Tuple iterPosY _ =
            moons # tickUntilSame moons comparePosY 0
        Tuple iterPosZ _ =
            moons # tickUntilSame moons comparePosZ 0
        Tuple iterVelX _ =
            moons # tickUntilSame moons compareVelX 0
        Tuple iterVelY _ =
            moons # tickUntilSame moons compareVelY 0
        Tuple iterVelZ _ =
            moons # tickUntilSame moons compareVelZ 0
    in
        [
            toNumber iterPosX,
            toNumber iterPosY,
            toNumber iterPosZ,
            toNumber iterVelX,
            toNumber iterVelY,
            toNumber iterVelZ
        ] # foldl lcm 1.0


main :: Effect Unit
main = do
    run2 # logShow
