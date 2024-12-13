--[[ 
PanView Plugin
==============
A Neovim plugin to preview files in Markdown format using Pandoc. 

Features:
- Command `PanViewCurrentBuffer` converts the current buffer to Markdown and displays it in a side buffer.
- Command `PanViewFile` accepts a file path as a parameter, converts it to Markdown, and displays the result in a side buffer.

Both buffers are opened in read-only mode for preview purposes.
]]


local M = {}

--- Detects the filetype based on the file extension.
-- Maps file extensions to their corresponding Pandoc input formats.
-- @param filepath string: The path to the file.
-- @return string: The detected filetype for Pandoc (e.g., "latex", "docx", "html").
local function detect_filetype(filepath)
    local ext = filepath:match("^.+%.(.+)$")
    local filetypes = {
        tex = "latex",
        docx = "docx",
        html = "html",
        odt = "odt",
        txt = "plain",
    }
    return filetypes[ext] or "plain"
end

--- Converts a file to Markdown format using Pandoc.
-- Executes a shell command to convert the specified file to Markdown using Pandoc.
-- @param filepath string: The path to the file to convert.
-- @param filetype string: The filetype to use as the input format for Pandoc.
-- @return string: The Markdown content as a string.
local function convert_to_markdown(filepath, filetype)
    local cmd = string.format("pandoc -f %s -t markdown %s", filetype, vim.fn.shellescape(filepath))
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result
end

--- Opens a side buffer to display the given content.
-- Creates a new buffer in a vertical split, sets it to read-only mode,
-- and displays the provided content.
-- @param content string: The content to display in the buffer.
local function open_side_buffer(content)
    vim.cmd("vsplit")
    local buf = vim.api.nvim_create_buf(false, true) -- Create a new unlisted buffer
    vim.api.nvim_set_current_buf(buf)
    -- Set the content of the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
    -- Set options to make the buffer read-only and set the filetype
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "readonly", true)
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    -- Optional: Prevent the buffer from being closed accidentally by marking it as non-modifiable
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
end


--- Converts the current buffer to Markdown and displays it in a side buffer.
-- Detects the filetype of the current buffer, uses Pandoc to convert it to Markdown,
-- and opens the result in a read-only side buffer.
-- Notifies the user if the buffer is unsaved or if the conversion fails.
function M.panview_current_buffer()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        vim.notify("Buffer não salvo. Salve o arquivo antes de usar o PanView.", vim.log.levels.ERROR)
        return
    end

    local filetype = detect_filetype(filepath)
    local markdown = convert_to_markdown(filepath, filetype)

    if markdown == "" then
        vim.notify("Falha ao converter o arquivo com Pandoc.", vim.log.levels.ERROR)
        return
    end

    open_side_buffer(markdown)
end

--- Converts a specified file to Markdown and displays it in a side buffer.
-- Accepts a file path as an argument, detects its filetype, converts it to Markdown
-- using Pandoc, and opens the result in a read-only side buffer.
-- Notifies the user if the file is not found or if the conversion fails.
-- @param args table: A table containing the file path as the first argument.
function M.panview_file(args)
    local filepath = args.fargs[1]
    if not filepath or filepath == "" then
        vim.notify("Você deve especificar o caminho de um arquivo.", vim.log.levels.ERROR)
        return
    end

    if vim.fn.filereadable(filepath) == 0 then
        vim.notify("Arquivo não encontrado: " .. filepath, vim.log.levels.ERROR)
        return
    end

    local filetype = detect_filetype(filepath)
    local markdown = convert_to_markdown(filepath, filetype)

    if markdown == "" then
        vim.notify("Falha ao converter o arquivo com Pandoc.", vim.log.levels.ERROR)
        return
    end

    open_side_buffer(markdown)
end

return M

