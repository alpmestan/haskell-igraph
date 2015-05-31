{-# LANGUAGE ForeignFunctionInterface #-}
module IGraph.Internal.Attribute where

import qualified Data.ByteString.Char8 as B
import Control.Monad
import Control.Applicative
import Foreign
import Foreign.C.Types
import Foreign.C.String
import System.IO.Unsafe (unsafePerformIO)

{#import IGraph.Internal.Graph #}
{#import IGraph.Internal.Data #}

#include "cbits/haskelligraph.c"

makeAttributeRecord :: Show a => String -> [a] -> AttributeRecord
makeAttributeRecord name xs = unsafePerformIO $ do
    ptr <- newCAString name
    value <- listToStrVector $ map (B.pack . show) xs
    return $ AttributeRecord ptr 2 value

data AttributeRecord = AttributeRecord CString Int StrVectorPtr
    deriving (Show)

instance Storable AttributeRecord where
    sizeOf _ = {#sizeof igraph_attribute_record_t #}
    alignment _ = {#alignof igraph_attribute_record_t #}
    peek p = AttributeRecord
        <$> ({#get igraph_attribute_record_t->name #} p)
        <*> liftM fromIntegral ({#get igraph_attribute_record_t->type #} p)
        <*> liftM castPtr ({#get igraph_attribute_record_t->value #} p)
    poke p (AttributeRecord name t vptr) = do
        {#set igraph_attribute_record_t.name #} p name
        {#set igraph_attribute_record_t.type #} p $ fromIntegral t
        {#set igraph_attribute_record_t.value #} p $ castPtr vptr

{#fun pure igraph_cattribute_has_attr as ^ { `IGraphPtr', `Int', `String' } -> `Bool' #}

{#fun igraph_cattribute_GAN_set as ^ { `IGraphPtr', `String', `Double' } -> `Int' #}

{#fun pure igraph_cattribute_GAN as ^ { `IGraphPtr', `String' } -> `Double' #}

{#fun pure igraph_cattribute_VAS as ^ { `IGraphPtr', `String', `Int' } -> `String' #}

{#fun pure igraph_cattribute_EAN as ^ { `IGraphPtr', `String', `Int' } -> `Double' #}

{#fun pure igraph_cattribute_EAS as ^ { `IGraphPtr', `String', `Int' } -> `String' #}

{#fun igraph_cattribute_EAS_setv as ^ { `IGraphPtr', `String', `StrVectorPtr' } -> `Int' #}
