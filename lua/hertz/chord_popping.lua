local function string2set(str)
    local t = {}
    for i = 1, #str do
        local c = str:sub(i,i)
        t[c] = true
    end
    return t
end

local function popping(env)
    if not env.engine.context:get_selected_candidate() then
        if env.auto_clear then
            env.engine.context:clear()
        end
    else
        env.engine.context:commit()
    end
end

local function processor(key_event, env)
    local engine = env.engine
    local schema = engine.schema
    local context = engine.context

    local input = context.input 
    local input_len = #input

    local min_len = env.popping_min

    if key_event:release() or key_event:ctrl() or key_event:alt() then
        return 2
    end

    local ch = key_event.keycode

    if ch < 0x20 or ch >= 0x7f then
        return 2
    end

    local key = string.char(ch)
    local prev = string.sub(input, -1)
    local first = string.sub(input, 1, 1)
    if #first == 0 then
        first = key
    end

    local is_alphabet = env.alphabet[key] or false
    local is_popping = env.popping_set[key] or false
    local is_prev_popping = env.popping_set[prev] or false
    local is_first_popping = env.popping_set[first] or false


    if env.popping_command and is_first_popping then
        return 2
    end

    if not is_alphabet then
        return 2
    end
    
    if is_prev_popping and not is_popping then
        popping(env)
    elseif not is_prev_popping and not is_popping and input_len >= min_len then
        popping(env)
    elseif input_len >= env.popping_max then
        popping(env)
    end

    return 2
end

local function init(env)
    local config = env.engine.schema.config

    env.popping_set = string2set(config:get_string("popping/popping_with"))
    env.alphabet = string2set(config:get_string("speller/alphabet"))
    env.popping_min = config:get_int("popping/min_length")
    env.popping_max = config:get_int("popping/max_length")
    env.auto_clear = config:get_bool("popping/auto_clear") or false
    env.popping_command = config:get_bool("popping/popping_command") or false
    env.enabled = true
end

return { init = init, func = processor }