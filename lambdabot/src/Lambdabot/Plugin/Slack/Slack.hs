module Lambdabot.Plugin.Slack.Slack
  ( slackPlugin
  ) where

import Lambdabot.IRC
import Lambdabot.Plugin
import Lambdabot.Monad
import Lambdabot.Util

import Web.Slack
import Web.Slack.Message

import Control.Concurrent.Lifted
import Control.Monad
import Control.Monad.Trans
import Data.IORef
import Data.List.Split
import qualified Data.Text as T


data IRCState = IRCState { apiKey :: Maybe String }

type IRC = ModuleT IRCState LB

slackPlugin :: Module IRCState
slackPlugin = newModule
  { moduleCmds = return
      [ (command "slack-connect")
          { help = say "slack-connect tag.  connect to the slack api"
          , process = \rest ->
              lift online
          }
      , (command "slack-api-key")
          { privileged = True
          , help = say "slack-api-key api-key.  set api-key for next slack-connect command"
          , process = \rest ->
              case splitOn " " rest of
                key:_ -> modifyMS (\ms -> ms { apiKey = Just key })
                _     -> say "Not enough parameters!"
          }
      ]
  , moduleDefState = return IRCState { apiKey = Nothing }
  }

online :: IRC ()
online = do
  reqref <- io $ newIORef Nothing
  resref <- io $ newIORef Nothing
  addServer "" $ \msg -> do
    io $ writeIORef resref (Just msg)
    io $ print ("addServer", msg)
  Just key <- apiKey `fmap` readMS
  modifyMS (\ms -> ms { apiKey = Nothing })
  lb . void . fork . forever $ do
    (readerLoop reqref resref key)
  lb . void . fork . forever $ do
    (messageDelay >> receivedLoop reqref)
  return ()

readerLoop :: IORef (Maybe IrcMessage) -> IORef (Maybe IrcMessage) -> String -> LB ()
readerLoop reqref resref key = do
  io $ runBot (SlackConfig { _slackApiToken = key }) (slackBot reqref resref) ()
  return ()

receivedLoop :: IORef (Maybe IrcMessage) -> LB ()
receivedLoop reqref = do
  req <- io $ readIORef reqref
  case req of
    Just msg -> do
      received msg
      io $ writeIORef reqref Nothing
      io $ print ("received", req)
    _ -> return ()

messageDelay :: LB ()
messageDelay = io $ threadDelay 10000

decodeMessage :: String -> IrcMessage
decodeMessage line =
  -- let (prefix, rest1) = decodePrefix (,) line
  --     (cmd, rest2)    = decodeCmd (,) rest1
  --     params          = decodeParams rest2
  IrcMessage { ircMsgServer = "", ircMsgLBName = "", ircMsgPrefix = "",
               ircMsgCommand = line, ircMsgParams = [""] }
  -- where
  --   decodePrefix k (':':cs) = decodePrefix' k cs
  --     where decodePrefix' j ""       = j "" ""
  --           decodePrefix' j (' ':ds) = j "" ds
  --           decodePrefix' j (c:ds)   = decodePrefix' (j . (c:)) ds

  --   decodePrefix k cs = k "" cs

  --   decodeCmd k []       = k "" ""
  --   decodeCmd k (' ':cs) = k "" cs
  --   decodeCmd k (c:cs)   = decodeCmd (k . (c:)) cs

  --   decodeParams :: String -> [String]
  --   decodeParams xs = decodeParams' [] [] xs
  --     where
  --       decodeParams' param params []
  --         | null param = reverse params
  --         | otherwise  = reverse (reverse param : params)
  --       decodeParams' param params (' ' : cs)
  --         | null param = decodeParams' [] params cs
  --         | otherwise  = decodeParams' [] (reverse param : params) cs
  --       decodeParams' param params rest@(c@':' : cs)
  --         | null param = reverse (rest : params)
  --         | otherwise  = decodeParams' (c:param) params cs
  --       decodeParams' param params (c:cs) = decodeParams' (c:param) params cs

slackBot :: IORef (Maybe IrcMessage) -> IORef (Maybe IrcMessage) -> SlackBot ()
slackBot reqref resref (Message cid _ msg _ _ _) = do
  io $ writeIORef reqref $ Just $ decodeMessage $ T.unpack msg
  io $ print ("req", msg)
  res <- io $ readIORef resref
  io $ print ("res", res)
  -- sendMessage cid msg

slackBot _ _ _ = return ()
