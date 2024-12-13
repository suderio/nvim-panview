local config = require("nvim-panview.config")

--- Detects the filetype based on the file extension.
-- Maps file extensions to their corresponding Pandoc input formats.
-- @param filepath string: The path to the file.
-- @return string: The detected filetype for Pandoc (e.g., "latex", "docx", "html").
function Detect_filetype(filepath)
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
function Convert_to_markdown(filepath, filetype)
    local cmd = string.format("pandoc -f %s -t markdown %s", filetype, vim.fn.shellescape(filepath))
    local handle = io.popen(cmd)
    if handle == nil then
      vim.notify(string.format("Error when calling %s", cmd), vim.log.levels.ERROR)
      return
    end
    local result = handle:read("*a")
    handle:close()
    return result
end

--- Opens a side buffer to display the given content.
-- Creates a new buffer in a vertical split, sets it to read-only mode,
-- and displays the provided content.
-- @param content string: The content to display in the buffer.
function Open_side_buffer(content)
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

