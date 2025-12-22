-- EZPZBanking_Hooks
EZPZBanking_Hooks = EZPZBanking_Hooks or {}

function EZPZBanking_Hooks.wrapFunction(tbl, funcName)
    if not tbl["_original_" .. funcName] then
        tbl["_original_" .. funcName] = tbl[funcName]

        tbl[funcName] = function(...)
            local result = { tbl["_original_" .. funcName](...) }

            local hooks = EZPZBanking_Hooks[funcName]
            if hooks then
                for _, hook in ipairs(hooks) do
                    local ok, err = pcall(hook, result, ...)
                    if not ok then
                        print("[EZPZBanking] Error: Hook error in " .. funcName .. ": " .. tostring(err))
                    end
                end
            end
            -- return table.unpack(result)
        end
    end
end

function EZPZBanking_Hooks.add(funcName, callback)
    EZPZBanking_Hooks[funcName] = EZPZBanking_Hooks[funcName] or {}
    table.insert(EZPZBanking_Hooks[funcName], callback)
end