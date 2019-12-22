module Main where

import Prelude
import Effect (Effect)
import Effect.Console (logShow)
import Debug.Trace
import Data.Foldable
import Math
import Data.Int

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


tick :: Int -> Array Moon -> Array Moon
tick iter moons =
    if iter >= 10 then
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

moons :: Array Moon
moons =
    [
        newMoon (-1) 0 2,
        newMoon 2 (-10) (-7),
        newMoon 4 (-8) 8,
        newMoon 3 5 (-1)
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

run :: Number
run =
    moons # tick 0 # totalEnergy

main :: Effect Unit
main = do
    run # logShow
