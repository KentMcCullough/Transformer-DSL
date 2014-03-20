# Transformer-DSL

## What's this?

A [domain specific language](1) for CoreAnimation Transformations ([CATransform3D](2))

[1]: http://en.wikipedia.org/wiki/Domain_specific_language
[2]: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/CoreAnimation_functions/Reference/reference.html

Instead of writing code like:

    CATransform3D *theTransform = CATransform3DScale(CATransform3DMakeTranslation(1, 2, 0), 10, 10, 1);
    
Write code like this:

    #import "NIMTransformFormatter.h"

    CATransform3D theTransform = CATransform3DMakeWithFormat(@"translate(1,2) | scale(10,10,1.0)");

Or even shorter:

    CATransform3D theTransform = CATransform3DMakeWithFormat(@"t(1,2) | s(10,10,1.0)");

Or if you have a reason to use the class directly.:

    CATransform3D theTransform = [[NIMTransformFormatter formatterWithFormat:@"t(1,2) | s(10,10,1.0)"] CATransform3D];
    
## What's the syntax look like?

Currently it looks (in theory) like this in Backus–Naur Form:

    <operation-name>  ::= "translate" | "scale" | "rotate" | "identity"
    <placeholder>     ::= "%f"
    <parameter>       ::= <floating-point-number> | <placeholder>
    <parameter-list>  ::= <parameter> | <parameter-list> "," <parameter>
    <operation>       ::= <operation-name> "(" <parameter-list> ")"
    <concat-operator> ::= "|"
    <operation-list>  ::= <operation> | <concat-operator> <operation-list>

The key parts to realise are operations look a bit like functions and are concatenated using the | (vertical bar) character.

Note that operation names are case insensitive and can be shortened to just the first unique character ("t" for "translate" for example).

## Formatting examples

This returns just the matrix identity. You probably won't ever need to use this,

    identity()

This returns the identity matrix scaled by 10.0 X and 10.0 Y and 1.0 Z.

    identity() | scale(10, 10, 1)
    
But the identity matrix is implied. So the previous format is equivalent to the this one:

    scale(10, 10, 1)

We can infer the Z scale. Any parameter for a scale operation is inferred to be 1.0:

    scale(10, 10)

Here's a translate operation, 100 pixels down the x-axis:

    translate(-100, 0, 0)

But of course we can infer the other two axes:

    translate(-100)

Let's put these together:

    scale(10, 10) | translate(-100)

Let's shorten this even more

    s(10,10) | t(-100)

## What about parameters?

Obviously you won't be passing in constants to every transformation. So the transformation strings are first passed through sprintf formatting. This allows you to write code that looks like:

    CATransform3D *theTransform = CATransform3DMakeWithFormat(@"translate(%f,%f) | scale(10,10,1.0)", X, Y);

## But why?

Creating complex transformations with multiple, nested functions is a pain. You end up making code that is fiddly and hard to change rapidly, for example if you need to reorder your transformation operations or add in another operation between other options.

Creating a transformation from using this domain specific language is extremely easy. The operations aren't nested so you can easily read the operations from left to right. You can easily reorder operations and insert operations anywhere into the operation list.

## What else could this be used for?

One use for this would be if you wanted to store transformations in data (in your plist or your JSON files). Having a string based representation of transforms would be quite handy. For maximuse usefulness we'd need to also support going from a matrix to a string. See the Further Ideas section

## Performance?

This DSL is a _lot_ slower than doing the operations by hand:

    2014-03-20 10:34:49.807 TransformTest[40682:303] Time for non-parametized expression: 0.117223
    2014-03-20 10:34:50.840 TransformTest[40682:303] Time for parametized expression: 1.03206
    2014-03-20 10:34:50.842 TransformTest[40682:303] Time for raw CA function calls: 0.00161803
    2014-03-20 10:34:50.843 TransformTest[40682:303] Slow-down factor for non-parametrized: 72.4481
    2014-03-20 10:34:50.843 TransformTest[40682:303] Slow-down factor for parametrized: 637.852
    Program ended with exit code: 0

This means using a format string without parameters is about 72 times slower than performing the transformation using CA functions. And using a format string with parameters is about 600 times slower. The reason for the difference in performance is that non-parametised expressions are easily cached - and the format is only parsed once.

Is this too slow? Well it depends what you're doing with your transformations. If you're just using these transformations to compute the before and after values of an animation it might be ok. If you're doing your own animations and computing transformations at 60 fps it might be too slow.

## License

BSD 2-Clause see LICENSE file.

## Further ideas

* More optimisation. Pretty sure I can get the performance of parametised expressions down by parsing the expression, caching that and then replacing the terms during later calls. I can also improve the general perform by dropping down to C.
* Named parameters: translate(z = -100)
* Use of degree symbol ° in rotations.
* Write code to support going from any arbitrary matrix to a string. See [Computing Euler angles from a rotation matrix](http://www.soi.city.ac.uk/~sbbh653/publications/euler.pdf) for more information. Or support a matrix3D() operation.
* Implement an "asSourceCode" method that returns the source for the transformations - either as a series of nested functions or as the final transformation with parameters pre computed.
* Pass in a base transformation - instead of working off the implied base transformation (thanks @ntakayama)