{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
module Codec.Picture.VectorByteConversion( blitVector
                                         , toByteString
                                         , imageFromUnsafePtr ) where

import Data.Word( Word8 )
import Data.Vector.Storable( Vector, unsafeToForeignPtr, unsafeFromForeignPtr0 )
import Foreign.ForeignPtr.Safe( ForeignPtr, castForeignPtr )
import Foreign.Storable( Storable, sizeOf )

import qualified Data.ByteString as B
import qualified Data.ByteString.Internal as S

import Codec.Picture.Types

blitVector :: Vector Word8 -> Int -> Int -> B.ByteString
blitVector vec atIndex blitSize = S.PS ptr (offset + atIndex) blitSize
  where (ptr, offset, _length) = unsafeToForeignPtr vec

toByteString :: forall a. (Storable a) => Vector a -> B.ByteString
toByteString vec = S.PS (castForeignPtr ptr) offset (len * size)
  where (ptr, offset, len) = unsafeToForeignPtr vec
        size = sizeOf (undefined :: a)

-- | Import a image from an unsafe pointer
-- The pointer must have a size of width * height * componentCount px
imageFromUnsafePtr :: forall px
                    . (Pixel px, (PixelBaseComponent px) ~ Word8)
                   => Int -- ^ Width in pixels
                   -> Int -- ^ Height in pixels
                   -> ForeignPtr Word8 -- ^ Pointer to the raw data
                   -> Image px
imageFromUnsafePtr width height ptr =
    Image width height $ unsafeFromForeignPtr0 ptr size
      where compCount = componentCount (undefined :: px)
            size = width * height * compCount

