-- Demonstration of the Lua Stream API
require "stream"

-- Here are some helper functions:
function isEven(x)
    return x % 2 == 0
end
function square(x)
    return x*x
end
function ident(x)
    return x
end
function myavg(iter)
    local sum = 0
    local count = 0;
    for e in iter do
        count = count + 1
        sum = sum + e
    end
    if count == 0 then
        return nil
    else
        return sum/count
    end
end
function range(s,e)
    local count = 0
    return function()
        local result = s+count
        if result<=e then
            count=count+1
            return result
        else
            return nil
        end
    end
end
function mult(f)
    return function(x)
        return f*x
    end
end
function countdown(x)
    local result = {}
    for i=1,x+1 do
        result[i]=x+1-i
    end
    return result
end
function fibbon(x)
    local f = {}
    if x > 0 then
        f[1] = 1
        if x > 1 then
            f[2] = 1
            for i=3,x do
                f[i] = f[i-2] + f[i-1]
            end
        end
    end
    return f
end
function num(i)
    return function()
        return i
    end
end
function sum(a,b)
    return a+b
end

-- Here starts the demo:

print("iter")
for i in stream({1,2,3,4,5}).iter() do
    print(i)
end

print("foreach")
stream({1,2,3,4,5}).foreach(print)

print("filter")
stream({1,2,3,4,5,6,7,8,9}).filter(isEven).foreach(print)

print("reverse")
stream({1,2,3,4,5}).reverse().foreach(print)

print("sort")
stream({5,7,6,3,4,1,2,8,9}).sort().foreach(print)

print("map")
stream({1,2,3,4,5}).map(square).foreach(print)

print("next")
local s1 = stream({1,2,3,4,5})
local first = s1.next()
print(first)
local second = s1.next()
print(second)

print("last")
local last = stream({1,2,3,4,5}).last()
print(last)

print("max")
local max = stream({5,7,6,3,4,1,2,8,9}).max()
print(max)

print("min")
local min = stream({5,7,6,3,4,1,2,8,9}).min()
print(min)

print("sum")
local _sum = stream({1,2,3,4,5}).sum()
print(_sum)

print("avg")
local avg = stream({5,7,6,3,4,1,2,8,9}).avg()
print(avg)

print("collect(myavg)")
local _myavg = stream({5,7,6,3,4,1,2,8,9}).collect(myavg)
print(_myavg)

print("toarray")
local array = stream({1,2,3,4,5}).toarray()
for i=1,#array do
    print(array[i])
end

print("range")
stream(range(1,5)).foreach(print)

print("limit")
stream(math.random).limit(5).foreach(print)

print("count")
local count = stream({1,2,3,4,5}).count()
print(count)

print("skip")
stream({1,2,3,4,5,6,7,8,9}).skip(5).foreach(print)

print("reverse")
stream({1,2,3,4,5}).reverse().foreach(print)

print("distinct")
stream({1,2,3,2,4,2,5,2,5,1}).distinct().foreach(print)

print("peek")
stream({1,2,3,4}).peek(print).last()

print("allmatch")
local allmatch = stream({2,4,6,8}).allmatch(isEven)
print(allmatch)

print("anymatch")
local anymatch = stream({1,2,3}).anymatch(isEven)
print(anymatch)

print("nonematch")
local nonematch = stream({1,3,5,7}).nonematch(isEven)
print(nonematch)

print("flatmap")
stream({0,4,5}).flatmap(fibbon).foreach(print)

print("flatten")
stream({{1,2,3},{4,5},{6},{},{7,8,9}}).flatten().foreach(print)

print("concat 1")
stream({1,2,3,4,5}).concat(stream({6,7,8,9})).foreach(print)

print("concat 2")
stream({1,2,3}).concat(stream({4,5,6}),stream({7,8,9})).foreach(print)

print("group")
local group = stream({1,2,3,4,5,6,7,8,9}).group(isEven)
stream(group[true]).foreach(print)
stream(group[false]).foreach(print)

print("split")
local even,odd = stream(range(1,10)).split(isEven)
even.foreach(print)
odd.foreach(print)

print("reduce")
local _sum = stream({1,2,3,4,5}).reduce(0,sum)
print(_sum)
