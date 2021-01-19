module Env where

import Data.Nullable (Nullable)
import Effect (Effect)

foreign import hostEnv :: Effect (Nullable String)

foreign import portEnv :: Effect (Nullable Int)
