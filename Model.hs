module Model where

import Prelude
import Yesod
import Data.Text (Text)
import Database.Persist.Quasi

type Price = Double
type Qty   = Int

data Size = Small
          | Medium
          | Large
          deriving (Show, Read, Eq, Ord, Enum, Bounded)

derivePersistField "Size"

-- You can define all of your database entities in the entities file.
-- You can find more information on persistent and how to declare entities
-- at:
-- http://www.yesodweb.com/book/persistent/
share [mkPersist sqlSettings, mkMigrate "migrateAll"]
    $(persistFileWith lowerCaseSettings "config/models")
