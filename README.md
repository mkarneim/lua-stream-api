Lua Stream API - A Fluent Stream API for Lua
=================================================
Author: Michael Karneim

Project Homepage: http://github.com/mkarneim/lua-stream-api

About
-----
The Lua Stream API brings the benefits of the stream-based functional programming style to
the [Lua language](http://lua.org).
It provides a function called ```stream``` that produces a simple wrapper object for
Lua arrays and iterator functions. This gives you the power of composing several
stream operations into a single stream pipeline.

For example, a simple stream pipeline could look like this:

```lua
stream({3,4,5,1,2,3,4,4,4}).distinct().sort().foreach(print)
```
which emits the following output:
```lua
1
2
3
4
5
```

License and Dependencies
------------------------
The source code of the Lua Stream API is in the PUBLIC DOMAIN.
For more information please read the [LICENSE](http://github.com/mkarneim/lua-stream-api/blob/master/LICENSE) file.

Supported Functions
-------------------

### Creating a Stream
* ```stream()```
* ```stream(array)```
* ```stream(iter_func)```

### Intermediate Operations
* ```concat(streams...) -> stream```
* ```distinct() -> stream```
* ```filter(predicate) -> stream```
* ```flatmap(func) -> stream```
* ```flatten() -> stream```
* ```limit(maxnum) -> stream```
* ```map(func) -> stream```
* ```peek(consumer) -> stream```
* ```reverse() -> stream```
* ```skip(n) -> stream```
* ```sort(comparator) -> stream```
* ```split(func) -> stream, stream```

### Terminal Operations
* ```allmatch(predicate) -> boolean```
* ```anymatch(predicate) -> boolean```
* ```avg() -> number```
* ```collect(collector) -> any```
* ```count() -> number```
* ```forach(c) -> nil```
* ```group(func) -> table```
* ```iter() -> function```
* ```last() -> any```
* ```max(comparator) -> any```
* ```min(comparator) -> any```
* ```next() -> any```
* ```nonematch(predicate) -> boolean```
* ```reduce(init, op) -> any```
* ```sum() -> number```
* ```toarray() -> table```

Getting Started
---------------
The Lua Stream API consists of a single file called ```stream.lua```. Just [download it](https://raw.githubusercontent.com/mkarneim/lua-stream-api/master/stream.lua) into
your project folder and include it into your program with ```require "stream"```.

### Creating a new stream from an array
You can create a new stream from any *Lua table*, provided that the table is an array indexed with consecutive numbers from 1 to n, containing no ```nil``` values (or, to be more precise, only as trailing elements. ```nil``` values can never be part of the stream).

Here is an example:
```lua
a = {}
a[1] = 100.23
a[2] = -12
a[3] = "42"

st = stream(a)
```

Of course, you can do it also *inline*:
```lua
st = stream({100.23, -12, "42"})
```

To print the contents to screen you can use ```foreach()```:
```lua
st.foreach(print)
```
This will produce the following output:
```lua
100.23
-12
42
```
Later we will go into more details of the ```foreach()``` operation.

For now, just let's have a look into another powerful alternative to create a stream.

### Creating a new stream form an iterator function
Internally each stream works with a *Lua iterator function*.
This is a parameterless function that produces a new element for each call.

You can create a new stream from any such function:
```lua
function zeros()
    return 0
end

st = stream(zeros)
```
Please note, that this creates an infinite stream of zeros. When you append  
a [terminal operation](#terminal-operations) to the end of the pipeline it will
actually never terminate:
```lua
stream(zeros).foreach(print)
0
0
0
0
.
.
.
Arrrgh!
```
To prevent this from happening you could ```limit``` the number of elements:

```lua
st.limit(100)
```

For example, this produces an array of 100 random numbers:
```lua
numbers = stream(math.random).limit(100).toarray()
```
Please note that ```toarray()```, like ```foreach()```, is a [terminal operation](#terminal-operations), which
means that it consumes elements from the stream. After this call the stream is
completely empty.

Another option to limit the number of elements is by limiting the iterator function itself.
This can be done by returning a ```nil``` value when the production is finished.

Here is an example. The ```range()``` function returns an iterator function
that produces consecutive integers in a specified range:
```lua
function range(s,e)
    local count = 0
    -- return an iterator function for numbers from s to e
    return function()
        local result = s+count
        if result<=e then
            count=count+1
            return result
        else
            -- this will stop any consumer from doing more calls
            return nil
        end
    end
end

numbers = stream(range(100,200)).toarray()
```
This produces an array with all integer numbers between 100 and 200 and assigns it to the ```numbers``` variable.  

So far, so good. Now that you know how to create a stream, let's see what we can do with it.

### Looping over the elements using the iter() operation
Further above you have seen that you can print all elements by using the ```forach()``` operation.
But this is not the only way to do it.

Since interally the stream alyways maintains an iterator function, you can also use it to process its content.
You can access it by calling ```iter()```.

The following example shows how to process all elements with a standard Lua ```for ... in ... do``` loop:
```lua
for i in st.iter() do
    -- do something with i, e.g. print it
    print(i)
end
```
This prints all elements of the stream to the output.

Please note that although ```iter()``` is a [terminal operation](#terminal-operations), it does not
consume all elements immediately. Instead it does it lazily - element by element - whenever the produced iterator function is called.
So, if you break from the loop before all elements are consumed, there will be elements left on the stream.

### Looping over the elements using the next() operation
If you dont want to consume all elements at once but rather getting the first element of the stream, you may want to use the ```next()``` operation.

```lua
st = stream({1,2,3})
print(st.next())
print(st.next())
```
This produces the following output:
```lua
1
2
```

### Looping over the elements with a consumer function
Another option for getting all elements of the stream is the ```foreach()``` operation.
We have used it already when we called it with the standard Lua ```print``` function in the examples above.

By using the ```foreach(consumer)``` operation you can loop over the stream's content by calling it with a *consumer function*.
This is any function with a single parameter.
It will be called repeatedly for each element until the stream is empty.

The following code prints all elements to the output:
```lua
st.foreach(function(e) print(e) end)
```

Or, even shorter, as we already have seen, just use the reference to the built-in ```print()``` function:
```lua
st.foreach(print)
```

Now, that we know how how to access the elements of the stream, let's see how we can modify it.
### Filtering Elements
Element-filtering is, besides *element-mapping*, one of the most used applications of stream pipelines.

It belongs to the group of [intermediate operations](#intermediate-operations). That means, when you append one of those to a stream, you actually are creating a new stream that is lazily backed by the former one, and which extends the pipeline by one more step.
Please note, that only then, when you call a terminal operation on the last part of the pipeline, it will actually pull elements from upstream. This is where the name *pipeline* comes from: not until you "suck" at the end, the elements are pulled from the line of predecessing streams, going though all intermediate operations that are placed in between.

By appending a ```filter(predicate)``` operation holding a *predicate function*, you can specify which elements should be passed downstream.
A predicate function is any function with a single parameter. It should return ```true``` if the argument should be passed down the stream, ```false``` otherwise.

Here is an example:
```lua
function is_even(x)
    return x % 2 == 0
end

stream({1,2,3,4,5,6,7,8,9}).filter(is_even).foreach(print)
```
This prints a stream of only even elements to the output:
```lua
2
4
6
8
```

*... More to come ...*

In the meanwhile you might want to browse the [examples](http://github.com/mkarneim/lua-stream-api/blob/master/examples.lua).
