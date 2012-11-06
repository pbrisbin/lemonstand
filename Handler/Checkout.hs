module Handler.Checkout where

import Import

lemonadeForm :: Form Lemonade
lemonadeForm = renderBootstrap $ Lemonade
    <$> pure Nothing
    <*> areq (selectField optionsEnum) "Size" Nothing
    <*> pure 0.0
    <*> areq intField "Quantiy" Nothing

getCheckoutR :: Handler RepHtml
getCheckoutR = do
    uid <- requireAuthId

    ((res,form), enctype) <- runFormPost $ lemonadeForm

    case res of
        FormSuccess l -> do
            oid <- processOrder uid l
            redirect $ ThankYouR oid

        _ -> return ()

    defaultLayout $ do
        setTitle "Checkout"
        $(widgetFile "checkout")

postCheckoutR :: Handler RepHtml
postCheckoutR = getCheckoutR

processOrder :: UserId -> Lemonade -> Handler OrderId
processOrder uid l = runDB $ do
    oid <- insert (Order uid)
    _ <- insert l { lemonadeOrder = Just oid
                  , lemonadePrice = priceForSize $ lemonadeSize l
                  }

    return oid

    where
        priceForSize :: Size -> Price
        priceForSize Small  = 0.99
        priceForSize Medium = 1.99
        priceForSize Large  = 2.99

getThankYouR :: OrderId -> Handler RepHtml
getThankYouR oid = defaultLayout $ do
    setTitle "Thanks!"

    [whamlet|
        <h1>Thank You!
        <p>Your order is ##{toPathPiece oid}
        |]
