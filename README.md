# using-promises
"Slides" for a talk about the basics of promises.

This repo contains the "slides" for showing how promises can improve code. It starts with a [UICollectionView tutorial from Ray Wenderlich](https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started).

Each slide is tagged.

Slide 1:

 * Flickr.searchFlickrForTerm(_: completion) is a long function. One-hundered, elven lines total (including white space to keep it neat.) The bulk of this function is a single closure that is 100 lines long.
 * It uses a completion block to "return" its results. The block has both `results` and `error` optional parameters.
 * What if both contain values? What if they are both empty?
 * Look af the first guard clause (line 33). Wouldn't it be nice to throw here? Why can't we?
 * Notice that in completion blocks like this, we can't simply return values, instead we must call the completion handler.
 
There are three things that you can do inside a function:
 # Return a value
 # Throw an error (if the function is marked `throws`)
 # Perform a side-effect.
 
In closures we can't really return a value or throw an error. So we are reduced to side-effects... The most error-prone kind of code.
