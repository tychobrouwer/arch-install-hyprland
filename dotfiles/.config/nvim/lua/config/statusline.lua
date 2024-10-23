local icons = require 'config.icons'

local M = {}

-- Don't show the command that produced the quickfix list.
vim.g.qf_disable_statusline = 1

-- Show the mode in my custom component instead.
vim.o.showmode = false

--- Keeps track of the highlight groups I've already created.
---@type table<string, boolean>
local statusline_hls = {}

---@param hl string
---@return string
function M.get_or_create_hl(hl)
  local hl_name = 'Statusline' .. hl

  if not statusline_hls[hl] then
    -- If not in the cache, create the highlight group using the icon's foreground color
    -- and the statusline's background color.
    local bg_hl = vim.api.nvim_get_hl(0, { name = 'StatusLine' })
    local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
    vim.api.nvim_set_hl(0, hl_name, { bg = ('#%06x'):format(bg_hl.bg), fg = ('#%06x'):format(fg_hl.fg) })
    statusline_hls[hl] = true
  end

  return hl_name
end

--- Current mode.
---@return string
function M.mode_component()
  -- Note that: \19 = ^S and \22 = ^V.
  local mode_to_str = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP-PENDING',
    ['nov'] = 'OP-PENDING',
    ['noV'] = 'OP-PENDING',
    ['no\22'] = 'OP-PENDING',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['nt'] = 'NORMAL',
    ['ntT'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['vs'] = 'VISUAL',
    ['V'] = 'VISUAL',
    ['Vs'] = 'VISUAL',
    ['\22'] = 'VISUAL',
    ['\22s'] = 'VISUAL',
    ['s'] = 'SELECT',
    ['S'] = 'SELECT',
    ['\19'] = 'SELECT',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rx'] = 'REPLACE',
    ['Rv'] = 'VIRT REPLACE',
    ['Rvc'] = 'VIRT REPLACE',
    ['Rvx'] = 'VIRT REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
  }

  -- Get the respective string to display.
  local mode = mode_to_str[vim.api.nvim_get_mode().mode] or 'UNKNOWN'

  -- Set the highlight group.
  local hl = 'Other'
  if mode:find 'NORMAL' then
    hl = 'Normal'
  elseif mode:find 'PENDING' then
    hl = 'Pending'
  elseif mode:find 'VISUAL' then
    hl = 'Visual'
  elseif mode:find 'INSERT' or mode:find 'SELECT' then
    hl = 'Insert'
  elseif mode:find 'COMMAND' or mode:find 'TERMINAL' or mode:find 'EX' then
    hl = 'Command'
  end

  -- Construct the bubble-like component.
  return table.concat {
    string.format(' %%#StatuslineModeSeparator%s# ', hl),
    string.format(' %%#StatuslineMode%s#%s ', hl, mode),
    string.format(' %%#StatuslineModeSeparator%s# ', hl),
  }
end

--- Git status (if any).
---@return string
function M.git_component()
  local head = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")

  if not head or head == '' then
    return ''
  end

  return string.format(' %s', head)
end

--- The current debugging status (if any).
---@return string?
function M.dap_component()
  if not package.loaded['dap'] or require('dap').status() == '' then
    return nil
  end

  return string.format('%%#%s#%s  %s', M.get_or_create_hl 'DapUIRestart', icons.misc.bug, require('dap').status())
end

---@type table<string, string?>
local progress_status = {
  client = nil,
  kind = nil,
  title = nil,
}

vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('mariasolos/statusline', { clear = true }),
  desc = 'Update LSP progress in statusline',
  pattern = { 'begin', 'end' },
  callback = function(args)
    -- This should in theory never happen, but I've seen weird errors.
    if not args.data then
      return
    end

    progress_status = {
      client = vim.lsp.get_client_by_id(args.data.client_id).name,
      kind = args.data.params.value.kind,
      title = args.data.params.value.title,
    }

    if progress_status.kind == 'end' then
      progress_status.title = nil
      -- Wait a bit before clearing the status.
      vim.defer_fn(function()
        vim.cmd.redrawstatus()
      end, 3000)
    else
      vim.cmd.redrawstatus()
    end
  end,
})
--- The latest LSP progress message.
---@return string
function M.lsp_progress_component()
  if not progress_status.client or not progress_status.title then
    return ''
  end

  -- Avoid noisy messages while typing.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return ''
  end

  return table.concat {
    '%#StatuslineSpinner#󱥸 ',
    string.format('%%#StatuslineTitle#%s  ', progress_status.client),
    string.format('%%#StatuslineItalic#%s...', progress_status.title),
  }
end

--- The buffer's filetype.
---@return string
function M.filetype_component()
  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[No Name]'
  end

  return filetype ~= '' and string.format('%%#StatuslineTitle# %s', filetype) or ''
end

--- File-content encoding for the current buffer.
---@return string
function M.encoding_component()
  local encoding = vim.opt.fileencoding:get()
  return encoding ~= '' and string.format('%%#StatuslineModeSeparatorOther# %s', encoding) or ''
end

--- The current line, total line count, and column position.
---@return string
function M.position_component()
  local line = vim.fn.line '.'
  local line_count = vim.api.nvim_buf_line_count(0)

  return string.format('%%#StatuslineTitle#%d/%d', line, line_count)
end

--- Renders the statusline.
---@return string
function M.render()
  ---@param components string[]
  ---@return string
  local function concat_components(components)
    local acc = components[1]
    for i = 2, #components do
      local component = components[i]
      if #component > 0 then
        acc = string.format('%s    %s', acc, component)
      end
    end
    return acc
  end

  return table.concat {
    concat_components {
      M.mode_component(),
      M.git_component(),
      M.dap_component() or M.lsp_progress_component(),
    },
    '%#StatusLine#%=',
    concat_components {
      M.filetype_component(),
      M.encoding_component(),
      M.position_component(),
    },
    ' ',
  }
end

vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

return M
