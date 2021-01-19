module Sentiment where

import Prelude
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Array (find, index, mapWithIndex)
import Data.Either (Either, either, note)
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Maybe (Maybe)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..), snd)
import Data.Tuple.Nested (Tuple7, tuple7, (/\))
import Effect.Exception (throw)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)

type Result
  = { probabilities :: Array Number, match :: Boolean }

type Response
  = { label :: String, results :: Array Result }

foreign import toxicityImpl :: Fn2 Number (Array String) (Effect (Promise (Array Response)))

toxicityImplCurried :: Number -> Array String -> Effect (Promise (Array Response))
toxicityImplCurried = runFn2 toxicityImpl

type Sentiment
  = { match :: Boolean
    , probability0 :: Number
    , probability1 :: Number
    }

type SentimentReport
  = { identityAttack :: Sentiment
    , insult :: Sentiment
    , obscene :: Sentiment
    , severeToxicity :: Sentiment
    , sexualExplicit :: Sentiment
    , threat :: Sentiment
    , toxicity :: Sentiment
    }

type SentimentResult
  = { label :: String
    , sentiment :: SentimentReport
    }

getSentimentX :: Result -> Maybe Sentiment
getSentimentX { probabilities, match } = do
  probability0 <- index probabilities 0
  probability1 <- index probabilities 1
  pure { match: match, probability0: probability0, probability1: probability1 }

getLabel :: String -> Array (Tuple Int Response) -> Either String Response
getLabel sentimentType labels = note errorMsg maybeLabel
  where
  maybeLabel = map snd $ find (\t -> (snd t).label == sentimentType) labels

  errorMsg = "Result doesn't contain " <> sentimentType

getSentiment :: Int -> Response -> Either String Sentiment
getSentiment i r@{ label, results } = do
  result <- note errorMsgIndex $ index results i
  sentiment <- note errorMsgProbabilities $ getSentimentX result
  pure sentiment
  where
  errorMsgIndex = "Response " <> (show r) <> "doesn't contain index " <> (show i)

  errorMsgProbabilities = "Response " <> (show r) <> "doesn't contain probabilities "

getSentimentResult :: Tuple7 Response Response Response Response Response Response Response -> Tuple Int String -> Either String SentimentResult
getSentimentResult (identityAttack /\ insult /\ obscene /\ severeToxicity /\ sexualExplicit /\ threat /\ toxic /\ unit) (Tuple index sentence) = do
  s1 <- getSentiment index identityAttack
  s2 <- getSentiment index insult
  s3 <- getSentiment index obscene
  s4 <- getSentiment index severeToxicity
  s5 <- getSentiment index sexualExplicit
  s6 <- getSentiment index threat
  s7 <- getSentiment index toxic
  pure { label: sentence, sentiment: { identityAttack: s1, insult: s2, obscene: s3, severeToxicity: s4, sexualExplicit: s5, threat: s6, toxicity: s7 } }

convert :: Array String -> Array Response -> Either String (Array SentimentResult)
convert sentences responses = do
  sevenTuple <- tuplified
  traverse (getSentimentResult sevenTuple) sentencesWithIndex
  where
  labels = mapWithIndex Tuple responses

  identityAttack = getLabel "identity_attack" labels

  insult = getLabel "insult" labels

  obscene = getLabel "obscene" labels

  severeToxicity = getLabel "severe_toxicity" labels

  sexualExplicit = getLabel "sexual_explicit" labels

  threat = getLabel "threat" labels

  toxic = getLabel "toxicity" labels

  tuplified :: Either String (Tuple7 Response Response Response Response Response Response Response)
  tuplified = tuple7 <$> identityAttack <*> insult <*> obscene <*> severeToxicity <*> sexualExplicit <*> threat <*> toxic

  sentencesWithIndex = mapWithIndex Tuple sentences

toxicity :: Number -> Array String -> Aff (Array Response)
toxicity threshold sentences = liftEffect (toxicityImplCurried threshold sentences) >>= Promise.toAff

orThrow ∷ ∀ a. Either String a -> Aff a
orThrow = either (throw >>> liftEffect) pure

toxicity' :: Number -> Array String -> Aff (Array SentimentResult)
toxicity' threshold sentences = do
  result <- liftEffect (toxicityImplCurried threshold sentences) >>= Promise.toAff
  orThrow $ convert sentences result
