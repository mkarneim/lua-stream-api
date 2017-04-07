-- Test cases for Lua Stream API

require "stream"

function check(cond, format, ...)
  local message = string.format("Test Failed! "..format, ...)
  assert(cond, message)
end

function assert_equals(aact, aexp)
  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing toarray")
  local aexp = {1,2,3,4,5}
  local aact = stream({1,2,3,4,5}).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing iter")
  local exp = 0
  for act in stream({1,2,3,4,5}).iter() do
    exp = exp + 1
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing foreach")
  local aexp = {1,2,3,4,5}
  local aact = {}
  local function consume(x)
    aact[#aact+1] = x
  end
  stream({1,2,3,4,5}).foreach(consume)

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,5 do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing filter")
  local function isEven(x)
      return x % 2 == 0
  end
  local aexp = {2,4,6,8}
  local aact = stream({1,2,3,4,5,6,7,8,9}).filter(isEven).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing reverse")
  local aexp = {5,4,3,2,1}
  local aact = stream({1,2,3,4,5}).reverse().toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing sort")
  local aexp = {1,2,3,4,5,6,7,8,9}
  local aact = stream({5,7,6,3,4,1,2,8,9}).sort().toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing map")
  local function square(x)
    return x*x
  end
  local aexp = {1,4,9,16,25}
  local aact = stream({1,2,3,4,5}).map(square).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing next")
  local aexp = {1,2,3}
  local aact = {}
  local s = stream({1,2,3})
  local e = nil
  for i=1,#aexp do
    aact[#aact+1] = s.next()
  end

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing last")
  local act = stream({2,2,2,2,1}).last()
  local exp = 1
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing count")
  local act = stream({1,2,3,4,5,6,7,8,9}).count()
  local exp = 9
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing max")
  local act = stream({5,7,6,3,4,1,2,8,9}).max()
  local exp = 9
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing min")
  local act = stream({5,7,6,3,4,1,2,8,9}).min()
  local exp = 1
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing sum")
  local act = stream({1,2,3,4,5}).sum()
  local exp = 15
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing avg")
  local act = stream({1,2,3,4,5,6,7,8,9}).avg()
  local exp = 5
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing collect")
  local aexp = {1,2,3,4,5}
  local aact = {}
  local function read(iter)
    for x in iter do
      aact[#aact+1] = x
    end
  end
  stream({1,2,3,4,5}).collect(read)

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,5 do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing limit")
  local aexp = {1,2,3}
  local aact = stream({1,2,3,4,5}).limit(3).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing skip")
  local aexp = {4,5}
  local aact = stream({1,2,3,4,5}).skip(3).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing reverse")
  local aexp = {5,4,3,2,1}
  local aact = stream({1,2,3,4,5}).reverse().toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing distinct")
  local aexp = {1,2,4,5,3}
  local aact = stream({1,2,4,2,4,2,5,3,5,1}).distinct().toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing peek")
  local aexp = {1,2,3,4,5}
  local aact = {}
  local function consume(x)
    aact[#aact+1] = x
  end
  stream({1,2,3,4,5}).peek(consume).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,5 do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing allmatch true")
  local function is_odd(x)
    return x%2==0
  end
  local act = stream({2,4,6,8,10}).allmatch(is_odd)
  local exp = true
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing allmatch false")
  local function is_odd(x)
    return x%2==0
  end
  local act = stream({2,4,6,8,11}).allmatch(is_odd)
  local exp = false
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing anymatch true")
  local function is_odd(x)
    return x%2==0
  end
  local act = stream({1,2,3}).anymatch(is_odd)
  local exp = true
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing anymatch false")
  local function is_odd(x)
    return x%2==0
  end
  local act = stream({1,3,5,7}).anymatch(is_odd)
  local exp = false
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing nonematch true")
  local function is_odd(x)
    return x%2==0
  end
  local act = stream({1,3,5,7}).nonematch(is_odd)
  local exp = true
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing nonematch false")
  local function is_odd(x)
    return x%2==0
  end
  local act = stream({1,2,3}).nonematch(is_odd)
  local exp = false
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing flatmap")
  local function duplicate(x)
    return {x,x}
  end
  local aexp = {1,1,2,2,3,3,4,4,5,5}
  local aact = stream({1,2,3,4,5}).flatmap(duplicate).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing flatten")
  local aexp = {1,2,3,4,5,6,7,8,9}
  local aact = stream({{1,2},{3,4,5,6},{7},{},{8,9}}).flatten().toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing concat 1")
  local aexp = {1,2,3,4,5,6,7,8,9}
  local aact = stream({1,2,3,4}).concat(stream({5,6,7,8,9})).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing concat 2")
  local aexp = {1,2,3,4,5,6,7,8,9}
  local aact = stream({1,2,3,4}).concat(stream({5,6}),stream({7,8,9})).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing merge 1")
  local aexp = {1,5,2,6,3,7,4,8,9}
  local aact = stream({1,2,3,4}).merge(stream({5,6,7,8,9})).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing merge 2")
  local aexp = {1,5,7,2,6,8,3,9,4}
  local aact = stream({1,2,3,4}).merge(stream({5,6}),stream({7,8,9})).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    check(act == exp, "act=%s, exp=%s", act, exp)
  end
end

do
  print("Testing group")
  local function is_odd(x)
    return x%2==0
  end
  local aexp1 = {2,4}
  local aexp2 = {1,3}
  local mact = stream({1,2,3,4}).group(is_odd)
  do
    local aact = mact[true]
    local aexp = aexp1
    check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
    for i=1,#aact do
      local exp = aexp[i]
      local act = aact[i]
      check(act == exp, "act=%s, exp=%s", act, exp)
      end
  end
  do
    local aact = mact[false]
    local aexp = aexp2
    check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
    for i=1,#aact do
      local exp = aexp[i]
      local act = aact[i]
      check(act == exp, "act=%s, exp=%s", act, exp)
      end
  end
end

do
  print("Testing split")
  local function is_odd(x)
    return x%2==0
  end
  local aexp1 = {2,4}
  local aexp2 = {1,3}
  local s1,s2 = stream({1,2,3,4}).split(is_odd)

  do
    local aexp = aexp1
    local aact = s1.toarray()
    check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
    for i=1,#aact do
      local exp = aexp[i]
      local act = aact[i]
      check(act == exp, "act=%s, exp=%s", act, exp)
    end
  end
  do
    local aexp = aexp2
    local aact = s2.toarray()
    check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
    for i=1,#aact do
      local exp = aexp[i]
      local act = aact[i]
      check(act == exp, "act=%s, exp=%s", act, exp)
    end
  end
end

do
  print("Testing reduce")
  local function add(a,b)
    return a+b
  end
  local act = stream({1,2,3,4,5}).reduce(0,add)
  local exp = 15
  check(act == exp, "act=%s, exp=%s", act, exp)
end

do
  print("Testing pack")
  local aexp = {{1,2},{3,4},{5,6},{7,8},{9}}
  local aact = stream({1,2,3,4,5,6,7,8,9}).pack(2).toarray()

  check(#aact == #aexp, "#aact=%s, #aexp=%s", #aact, #aexp)
  for i=1,#aact do
    local exp = aexp[i]
    local act = aact[i]
    assert_equals(act,exp)
  end
end
