-------------------------------------------------------
-- author : sky_allen
--  email : 894982165@qq.com
--   time : 2021/9/16 9:59:31
-------------------------------------------------------

-- global func

function int(num)
    return math.modf(num);
end

function integer(num, count)
    assert(type(num) == "number")
    if count == nil then
        count = 2;
    end

    if count >= 2 then
        if num < 100 then
            print("Warning: too small!")
        end
    end

    num = int(num);
    local numStr = tostring(num);
    if string.match(numStr, "-") then
        assert(count <= (#numStr - 2))
    else
        assert(count <= (#numStr - 1))
    end

    local charArr = string.to_char_arr(numStr);

    local counter = 0;
    for i = #charArr, 1, -1 do
        charArr[i] = "0";
        counter = counter + 1;
        if counter >= count then
            break ;
        end
    end

    return tonumber(table.concat(charArr));
end

function localize(id)
    return Language[id][LANGUAGE_KEY];
end

function readOnlyTable(t)
    local res = {}
    setmetatable(res, {
        __index = t,
        __newindex = function(t, _)
            error("Readonly " .. _, 2);
        end
    })
    return res;
end

function global(key, val)
    rawset(_G, key, val or false);
end

function getColor(a, b, c, d)
    return Color(a / 255, b / 255, c / 255, d / 255);
end

function SetActive(ui, arg)
    if arg then
        ui.gameObject:SetActive(true);
    else
        ui.gameObject:SetActive(false);
    end
end

function array2table(mono, uiType, isAll, func)
    local res = {};
    local array = nil;
    if isAll then
        array = mono:GetComponentsInChildren(typeof(uiType))
    else
        array = mono.transform:GetChildArray();
    end

    for i = 1, array.Length do
        local ui = array[i - 1];
        if uiType == Button then
            ui.onClick:AddListener(function()
                if func then
                    func(ui);
                end
            end)
        end
        table.insert(res, ui);
    end
    return res;
end

function create_enum_table(tbl, idx)
    local res = {}
    local index = idx or 0

    for i, v in ipairs(tbl) do
        res[v] = index + i
    end
    return readOnlyTable(res);
end

function assert_true(val, msg)
    assert(val, msg)
end

function randomSeed()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7));
end


-- arr

function table.countItems(t, func)
    local count = 0;
    for i, v in ipairs(t) do
        if func(v) then
            count = count + 1;
        end
    end

    return count;
end

function table.csv2table(csvStr)
    return string.split(csvStr, ",");
end

function table.table2csv(t)
    local resTable = {};
    for i, v in ipairs(t) do
        table.insert(resTable, v);
        if i ~= #t then
            table.insert(resTable, ",")
        end
    end
    return table.concat(resTable);
end

function table.checkAllType(t, str)
    local typeStr = type(t[1]);

    if str ~= nil then
        if typeStr ~= str then
            return false;
        end
    end

    for i, v in ipairs(t) do
        local curType = type(v);
        if curType ~= typeStr then
            return false;
        end
    end

    return true;
end

function table.all(t, func)
    for i, v in ipairs(t) do
        if func(v) == false then
            return false;
        end
    end
    return true;
end

function table.conversion(t)
    local res = {};
    for i, v in ipairs(t) do
        res[i] = tonumber(v);
    end
    return res;
end

function table.deep_copy(t)
    --[[    local function deep_copy(orig)
            local copy
            if type(orig) == "table" then
                copy = {}
                for orig_key, orig_value in next, orig, nil do
                    copy[deep_copy(orig_key)] = deep_copy(orig_value)
                end
                setmetatable(copy, deep_copy(getmetatable(orig)))
            else
                copy = orig
            end
            return copy
        end
        deep_copy(t);]]
end

function table.removeFirst(t)
    return table.remove(t, 1);
end

function table.real_len(t)
    return table.maxn(t);
end

function table.index_of(arr, val)

    for i, v in ipairs(arr) do
        if val == v then
            return i;
        end
    end

    return nil;
end

function table.exists(arr, fn)
    for i, v in ipairs(arr) do
        if fn(v) then
            return true;
        end
    end
    return false;
end

function table.find(arr, fn)
    for i, v in ipairs(arr) do
        if fn(v) then
            return v, i;
        end
    end
    return nil, nil;
end

function table.removeVal(arr, val)
    local _, i = table.find(arr, function(item)
        return item == val
    end)
    if not i then
        error("Arr don't contain the val " .. tostring(val), 2);
    else
        table.remove(arr, i)
    end
end

function table.find_all(arr, fn)
    local res = {};
    for i, v in ipairs(arr) do
        if fn(v) then
            res[#res + 1] = v;
        end
    end
    return res;
end

function table.contains(arr, val)
    for i, v in ipairs(arr) do
        if val == v then
            return true;
        end
    end
    return false;
end

function table.isSubset(big, small)
    local temp = table.intersection(big, small);
    return table.contentsEqual(temp, small);
end

function table.intersection(arr1, arr2)
    local res = {};
    table.sort(arr1);
    table.sort(arr2);

    local i, j = 1, 1;

    while ((i <= #arr1) and (j <= #arr2)) do
        if arr1[i] == arr2[j] then
            table.insert(res, arr1[i])
            i = i + 1;
            j = j + 1;
        elseif arr1[i] < arr2[j] then
            i = i + 1;
        else
            j = j + 1;
        end
    end
    return res;
end

function table.distinct(arr)
    local res = {};
    for i, v in ipairs(arr) do
        if not table.contains(res, v) then
            res[#res + 1] = v;
        end
    end
    return res;
end

function table.reverse(arr)
    local l = 1;
    local r = #arr;

    while l < r do
        arr[l], arr[r] = arr[r], arr[l];
        l = l + 1;
        r = r - 1;
    end
end

function table.add_range(arr, range)
    for i, v in ipairs(range) do
        arr[#arr + 1] = v;
    end
end

function table.clear(arr)
    while #arr > 0 do
        table.remove(arr);
    end
end

function table.sum(arr)
    local res = 0;
    for i, v in ipairs(arr) do
        res = res + v;
    end

    return res;
end

function table.foreach_operation(arr, fn)
    for i, v in ipairs(arr) do
        fn(arr, i);
    end
end

function table.print_arr(arr, other)
    local str = "";

    for i = 1, #arr do
        local interval = (i == #arr) and "" or " , ";
        str = str .. tostring(arr[i]) .. interval;
    end
    if other then
        print(other)
    end
    print(str);
end

function table.isIncreasing(t, increasingOne)
    for i = 1, #t - 1 do
        local first = t[i];
        local second = t[i + 1];

        local condition = first > second;
        if increasingOne ~= nil then
            condition = (first + 1) ~= (second);
        end

        if condition then
            return false;
        end
    end
    return true;
end

function table.print_nest_arr(nest_arr, other)
    if other then
        print(other)
    end
    for i, v in ipairs(nest_arr) do
        table.print_arr(v);
    end
end

function table.division(t, few)
    local fewNumber = int(#t / few);
    local res = {};

    for i = 1, few do
        res[i] = {};
    end

    local resIndex = 1;

    while (#t ~= 0) do
        local first = table.remove(t, 1);
        table.insert(res[resIndex], first);
        if (#res[resIndex] >= fewNumber) and (resIndex ~= few) then
            resIndex = resIndex + 1;
        end ;
    end

    assert(resIndex == #res);
    --table.print_nest_arr(res);
    return res;
end

function table.get_range(arr, start, count)
    local res = {};
    local endIndex = start + count - 1;
    for i = start, endIndex do
        res[#res + 1] = arr[i];
    end
    return res;
end

function table.insert_range(arr, start, range)
    table.reverse(range);
    for i, v in ipairs(range) do
        table.insert(arr, start, v);
    end
end

function table.remove_range(arr, start, count)
    local endIndex = start + count - 1;

    for i = start, endIndex do
        table.remove(arr, start);
    end
end

function table.swap(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i];
end

function table.to_count_hash(arr)
    local hash = {}

    for i, v in ipairs(arr) do
        if hash[v] then
            hash[v] = hash[v] + 1;
        else
            hash[v] = 1;
        end
    end

    return hash;
end

function table.average(arr)
    return table.sum(arr) / #arr;
end

function table.prefix_sum(arr)
    local sum_arr = {};
    for i = 1, #arr do
        local prefix_arr = table.get_range(arr, 1, i);
        local val = table.sum(prefix_arr);
        sum_arr[i] = val;
    end

    return sum_arr;
end

function table.get_repeat(item_val, count)
    local res = {}

    for i = 1, count do
        res[i] = item_val;
    end

    return res;
end

function table.get_random_item(arr)
    return arr[math.random(#arr)];
end

function table.filterItems(t, fT)
    --????????????,??????table??????????????????,??????fT???t??????
    for i, v in ipairs(fT) do
        table.removeVal(t, v);
    end
end

function table.differenceSet(t1, t2)
    local res = table.copy(t1);
    table.filterItems(res, t2);
    return res;
end

function table.copy(t)
    local res = {}

    for i, v in ipairs(t) do
        res[i] = v;
    end

    return res;
end

function table.copyMatrix(t)
    local res = {};
    for i, v in ipairs(t) do
        res[i] = {}
        for i1, v1 in ipairs(v) do
            res[i][i1] = v1;
        end
    end
    return res;
end

function table.selectItems(t, str)

    local res = {};
    for i, v in ipairs(t) do
        res[i] = v[str]
    end
    return res;
end


-- hash

function table.print_hash(hash, vIsArry)

    if table.contains_key(hash, 1) then
        error("Don't support key is number 1.")
    end

    for i, v in pairs(hash) do
        if vIsArry then
            local key = tostring(i);
            print("key:" .. key .. " " .. "val:");
            table.print_arr(v);
        else
            print(i, v);
        end
    end
end

function table.hash_count(hash)
    return #table.keys(hash);
end

function table.keys(hash)
    local res = {};
    for i, v in pairs(hash) do
        res[#res + 1] = i;
    end
    return res;
end

function table.values(hash)
    local res = {};
    for i, v in pairs(hash) do
        res[#res + 1] = v;
    end
    return res;
end

function table.contentsEqual(t1, t2)
    if #t1 ~= #t2 then
        return false;
    else
        table.sort(t1);
        table.sort(t2)

        for i, v in ipairs(t1) do
            if t1[i] ~= t2[i] then
                return false;
            end
        end
        return true;
    end
end

function table.contains_key(hash, key)
    return hash[key] ~= nil;
end

function table.contains_value(hash, val)
    local values = table.values(hash);
    return table.contains(values, val);
end

-- str

function string.haveEmpty(str)
    local temp = string.match(str, "%s");
    return temp ~= nil;
end

function string.value_of(str, index)
    return string.sub(str, index, index)
end

function string.index_of(str, char)
    for i = 1, #str do
        if string.value_of(str, i) == char then
            return i;
        end
    end
    return nil;
end

function string.starts_with(str, start)
    return str:sub(1, #start) == start;
end

function string.to_char_arr(str)
    local res = {};
    for i = 1, #str do
        res[i] = string.value_of(str, i);
    end
    return res;
end

function string.serialize(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. string.serialize(k) .. "]=" .. string.serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                lua = lua .. "[" .. string.serialize(k) .. "]=" .. string.serialize(v) .. ",\n"
            end
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end

function string.unserialize(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end

function string.get_pure_number(str)
    local temp = string.gsub(str, "%D+", "");
    if temp == "" then
        return 0;
    else
        return tonumber(temp);
    end
end

function string.format_foreign(digit)
    local a, b = math.modf(digit);
    local d_str = tostring(a):reverse();
    local t = {};
    local counter = 0;

    for i = 1, #d_str do
        table.insert(t, 1, string.value_of(d_str, i))
        counter = counter + 1;
        if counter == 3 and i ~= #d_str then
            table.insert(t, 1, ",")
            counter = 0;
        end
    end

    return table.concat(t);
end

function string.percent(n)
    local N = n * 100;
    return string.format("%.0f%%", N)
end

--math
function math.ratio(f)
    return math.random() <= f;
end

