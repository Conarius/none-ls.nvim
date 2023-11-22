local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
    name = "hlint",
    meta = {
        url = "https://github.com/ndmitchell/hlint",
        description = "Haskell source code suggestions",
    },
    method = DIAGNOSTICS,
    filetypes = { "haskell" },
    generator_opts = {
        command = "hlint",
        to_stdin = true,
        format = "raw",
        multiple_files = true,
        check_exit_code = function(code)
            return code < 1
        end,
        on_output = function(params)
            params.messages = {}
            local severity = vim.diagnostic.severity
            for _, output in pairs(params.output) do
                local filename = output.file
                for _, error in pairs(output.errors) do
                    local s = error.rule == "" or "ERROR" or "WARN"
                    table.insert(params.messages, {
                        row = error.line,
                        col = error.column,
                        message = error.message,
                        severity = severity[s],
                        filename = filename,
                        source = "hlint",
                    })
                end
            end
        end,
    },
    can_run = function()
        return require("null-ls.utils").is_executable("hlint")
    end,
})
