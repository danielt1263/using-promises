# using-promises
"Slides" for a talk about the basics of promises.

This repo contains the "slides" for showing how promises can improve code. It starts with a [UICollectionView tutorial from Ray Wenderlich](https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started).

Each slide is tagged.

## Slide 1:

 * Flickr.searchFlickrForTerm(_: completion) is a long function. One-hundred, elven lines total (including white space to keep it neat.) The bulk of this function is a single closure that is 100 lines long.
 * It uses a completion block to "return" its results. The block has both `results` and `error` optional parameters.
 * What if both contain values? What if they are both empty?
 * Look at the first guard clause (line 33). Wouldn't it be nice to throw here? Why can't we?
 * Notice that in completion blocks like this, we can't simply return values, instead we must call the completion handler.
 
There are three things that you can do inside a function:
 1. Return a value
 1. Throw an error (if the function is marked `throws`)
 1. Perform a side-effect.
 
In closures we can't really return a value or throw an error. So we are reduced to side-effects... The most error-prone kind of code.

## Slide 2:

First we need to choose a promise library. 

 * There are several in existence for Swift, some more elaborate than others. 
 * For this presentation I have chosen one of the smaller ones, a library by Soroush Khanlou called simply, ["Promise"](https://github.com/khanlou/Promise). 
 * This library is relatively easy to understand. 
 * We aren't going to do that though, instead we are going to learn how to *use* the library.

A promise is a way to represent a value that may exist at some point in the future. So we can:

 * Easily chain asynchronous operations.
 * Perform many independent asynchronous operations simultaneously and combine them into one result.

... and more! We will refactor the Flickr code to show this in action.

## Slide 3:

Now it's time to start using the library. In our first refactoring we will create a new function on URLSession that returns a Promise. We do that by wrapping the dataTask function.

 * Review the Promise initializer and how it has a `work` closure that supplies two other closures, `fulfill: (Value) -> Void` and `reject: (Error) -> Void`.
 * The Promise class sets up a level of indirection. Now you provide your success closure through a `then` method and the `catch` method is used to handle any error that occurs.
 * Note the `data` object on line 42 is a `Promise<Data>`. A variable that will hold the data once it comes back from the server and will provide it to any `then` closure that is attached to the promise. If there is an error, the promise will provide that to any closure that is bound to the `catch` method.

## Slide 4:

Here is an example of how promises handle thrown errors. Unlike the callback we are replacing, Promises allow errors to be thrown and will route those errors to the Promise's `catch` block. With promises, we get to use throw again!

 * Notice how everytime we wrap up a type in a promise the level of indentation goes down.
 * Before moving on to the next refactoring, examine the code from lines 46-81. Notice the error. This error couldn't exist if throwing had been allowed.

## Slide 5:

Here we are just checking the validity of the object returned from the JSON parsing.

 * Notice how we can chain `then` methods.
 * We can also attach the `catch` method to the last `then`.
 * Here the use of Promises and our ability to use `throw` again, has turned 35 lines of code into 14.
 * We fixed the error in the code.

## Slide 6:

Here we are doing more object extraction.

 * Notice how all the `completion(nil, APIError)` calls are getting rolled into the promise's `catch` clause.
 
