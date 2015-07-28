QTXLibrary is a collection of units for Smart Pascal, written by Jon Lennart Aasenden - the author of Smart Mobile Studio. The library demonstrates what can be achieved in Smart Pascal and introduces several powerful additions to the standard RTL.

First of all the library augments the popular iScroll.js library (included) to provide flicker-free, ultra-fast momentum scroll controls. The library also introduces a css3 scroll controller written directly in SMS (no external libraries required) which can be used to achieve the same thing.

Effects, much like you expect from jQuery and jQTouch is included - written in pure Smart Pascal as well.

If you use Smart Mobile Studio -- then this library is a must (!)

### Features ###

QTX extends all TW3CustomControl components with a wide range of effects. When you include qtx.effects in your uses clause, all TW3CustomControls expose these effect methods.

QTX provides TQTXDataset, which is a full in-memory dataset class. When working with data under HTML5 this is the way to go. Easily serialize the table to JSON for sending to your Delphi or NodeJS server (and visa versa).

QTX allows you to create style-sheets "on the fly", wrapped completely in a TObject decendant. This is perfect for injecting CSS3 GPU effects which can be applied to HTML elements.

QTX gives you (finally) a 100% accurate font measuring class. This is a must when creating pixel perfect custom controls. QTX makes it a snap to measure plain-text and rich markup .

QTX expands all TW3CustomControl decendants with tag attribute storage. TW3CustomControl creates it's HTML element during construction -- as such the handle for the element is always known. Being able to read and write to the data attributes of an element is a great way to store information in the TAG itself. This is used to great effect (pun intended) with the QTX effects unit, which stores information about the current effect and it's state directly in the tag - which means that updates and "busy" states can be tracked and tested without handle references.
QTX allows you to read and write attributes directly yourself, which makes for richer and more adaptive custom controls.

And much, much more!