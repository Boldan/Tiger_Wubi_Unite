-- prompt_filter.lua
-- encoding: utf-8
-- CC-BY-4.0

local function F(input, env)
    schema_name = env.engine.schema.config:get_string("schema/name")
    local segment = env.engine.context.composition:back()
    
    if segment then
        segment.prompt = "    [ " .. schema_name .. " ]"
        -- 保持原有的候选项不变
        for cand in input:iter() do
            yield(cand)
        end
    end
    
    return true
end

return F