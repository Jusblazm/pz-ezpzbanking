local lfs = require("lfs")

local BASE_DIR = "EZPZBanking/42.20/media/lua/shared/Translate"
local README_PATH = "README.md"
local LANGUAGES = {
    EN = "🇺🇸 English",
    AR = "🇦🇷 Argentina",
    CA = "🏴 Catalan",
    CH = "🇹🇼 Traditional Chinese",
    CN = "🇨🇳 Simplified Chinese",
    CS = "🇨🇿 Czech",
    DA = "🇩🇰 Danish",
    DE = "🇩🇪 German",
    ES = "🇪🇸 Spanish",
    FI = "🇫🇮 Finnish",
    FR = "🇫🇷 French",
    HU = "🇭🇺 Hungarian",
    ID = "🇮🇩 Indonesian",
    IT = "🇮🇹 Italian",
    JP = "🇯🇵 Japanese",
    KO = "🇰🇷 Korean",
    NL = "🇳🇱 Dutch",
    NO = "🇳🇴 Norwegian",
    PH = "🇵🇭 Filipino",
    PL = "🇵🇱 Polish",
    PT = "🇵🇹 Portuguese",
    PTBR = "🇧🇷 Brazilian Portuguese",
    RO = "🇷🇴 Romanian",
    RU = "🇷🇺 Russian",
    TH = "🇹🇭 Thai",
    TR = "🇹🇷 Turkish",
    UA = "🇺🇦 Ukrainian"
}

local function read_file(path)
    local f = assert(io.open(path, "rb"))
    local data = f:read("*all")
    f:close()
    return data
end

local function extract_keys_from_file(filepath)
    local keys = {}

    local text = read_file(filepath)
    for key in text:gmatch('"([^"]+)"%s*:') do
        keys[key] = true
    end
    return keys
end

-- get all keys in the English reference folder
local function get_reference_keys()
    local path = BASE_DIR .. "/EN"
    local keys = {}

    for file in lfs.dir(path) do
        if file:match("%.json$") then
            local file_keys = extract_keys_from_file(path .. "/" .. file)
            for k, _ in pairs(file_keys) do
                keys[k] = true
            end
        end
    end
    return keys
end

-- get all keys for a specific language
local function get_language_keys(lang_code)
    local path = BASE_DIR .. "/" .. lang_code
    local keys = {}

    local attr = lfs.attributes(path)
    if not attr or attr.mode ~= "directory" then
        return keys
    end

    for file in lfs.dir(path) do
        if file:match("%.json$") then
            local file_keys = extract_keys_from_file(path .. "/" .. file)
            for k, _ in pairs(file_keys) do
                keys[k] = true
            end
        end
    end
    return keys
end

local function generate_progress_bar(percent)
    local filled = math.floor(percent / 10 + 0.5)
    local bar = string.rep("█", filled) .. string.rep("░", 10 - filled)
    return string.format("%s %.0f%%", bar, percent)
end

local ORDERED_LANG_CODES = {
    "EN", "AR", "CA", "CH", "CN", "CS", "DA", "DE", "ES", "FI",
    "FR", "HU", "ID", "IT", "JP", "KO", "NL", "NO", "PH", "PL",
    "PT", "PTBR", "RO", "RU", "TH", "TR", "UA"
}

local function main()
    local ref_keys_map = get_reference_keys()
    local total_keys = 0
    for _ in pairs(ref_keys_map) do total_keys = total_keys + 1 end

    local progress_lines = {}
    local max_lang_width = 0

    for _, code in ipairs(ORDERED_LANG_CODES) do
        local name = LANGUAGES[code]
        if #name > max_lang_width then
            max_lang_width = #name
        end
    end

    for _, code in ipairs(ORDERED_LANG_CODES) do
        local name = LANGUAGES[code]
        local completed
        if code == "EN" then
            completed = total_keys
        else
            local lang_keys_map = get_language_keys(code)
            completed = 0
            for k, _ in pairs(ref_keys_map) do
                if lang_keys_map[k] then
                    completed = completed + 1
                end
            end
        end

        local percent = total_keys > 0 and (completed / total_keys * 100) or 0
        local bar = generate_progress_bar(percent)
        local status = (completed == total_keys and "✅ Done")
                    or (completed > 0 and "🔃 In Progress")
                    or "❌ Not Started"

        local lang_col_width = max_lang_width
        if code == "CA" then
            lang_col_width = lang_col_width - 5
        end

        table.insert(progress_lines,
            string.format("| %-" .. lang_col_width .. "s | %-13s | %d/%d     | %-13s |",
                name, bar, completed, total_keys, status))
    end

    local table_header = string.format(
        "| %-" .. max_lang_width - 6 .. "s | %-13s | %-9s | %-13s |\n" ..
        "|-%s-|-%s-|-%s-|-%s-|",
        "Language", "Progress", "Completed", "Status",
        string.rep("-", 23),
        string.rep("-", 13),
        string.rep("-", 9),
        string.rep("-", 13)
    )

    local full_table = table_header .. "\n" .. table.concat(progress_lines, "\n")
    -- print("<!-- AUTO-GENERATED-TABLE:START -->")
    print(full_table)
    -- print("<!-- AUTO-GENERATED-TABLE:END -->")
end

main()