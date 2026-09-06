-- Side-by-side markdown preview: your source in the left window, glow's
-- rendered output in a terminal buffer on the right, re-rendered every time
-- you save.
--
-- A terminal buffer is used rather than a normal one because glow emits ANSI
-- colour codes; a normal buffer would show them as literal escape sequences.
-- Terminal buffers cannot be re-run in place, so each refresh swaps in a fresh
-- one and wipes the old.

local M = {}

---@type { win: integer?, buf: integer?, src: integer?, group: integer? }
local state = {}

-- Rendering swaps buffers and touches windows, which itself fires WinResized.
-- Without this guard that autocmd would re-enter render in a loop.
local rendering = false

local function is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

function M.close()
  rendering = false
  if state.group then
    pcall(vim.api.nvim_del_augroup_by_id, state.group)
  end
  if is_open() then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end
  state = {}
end

function M.render()
  if not is_open() then
    return
  end
  if not (state.src and vim.api.nvim_buf_is_valid(state.src)) then
    return M.close()
  end

  local file = vim.api.nvim_buf_get_name(state.src)
  if file == "" then
    return
  end

  if rendering then
    return
  end
  rendering = true

  -- glow wraps to whatever width we give it, so track the window's real width.
  local width = math.max(40, vim.api.nvim_win_get_width(state.win) - 2)
  local old = state.buf
  local back = vim.api.nvim_get_current_win()

  -- Focus has to move into the preview window for `enew` and the terminal job
  -- to land there. pcall so a failure still restores focus below.
  local ok, err = pcall(function()
    vim.api.nvim_set_current_win(state.win)
    vim.cmd("enew")
    state.buf = vim.api.nvim_get_current_buf()
    vim.bo[state.buf].bufhidden = "wipe"
    vim.fn.jobstart({ "glow", "-s", "auto", "-w", tostring(width), file }, { term = true })
  end)

  -- Always hand focus back to where the user actually was.
  if vim.api.nvim_win_is_valid(back) then
    pcall(vim.api.nvim_set_current_win, back)
  end
  rendering = false

  if not ok then
    vim.notify("glow preview failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  if old and vim.api.nvim_buf_is_valid(old) then
    pcall(vim.api.nvim_buf_delete, old, { force = true })
  end
end

function M.open()
  if vim.fn.executable("glow") == 0 then
    vim.notify("glow is not on PATH — run `mise install glow`", vim.log.levels.ERROR)
    return
  end

  local src = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(src) == "" then
    vim.notify("Save the file first — glow renders from disk, not from the buffer", vim.log.levels.WARN)
    return
  end
  state.src = src

  local back = vim.api.nvim_get_current_win()
  vim.cmd("vsplit")
  state.win = vim.api.nvim_get_current_win()
  local wo = vim.wo[state.win]
  wo.number, wo.relativenumber, wo.signcolumn, wo.wrap = false, false, "no", false
  vim.api.nvim_set_current_win(back)

  M.render()

  state.group = vim.api.nvim_create_augroup("MdPreviewGlow", { clear = true })
  -- re-render on save
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = state.group,
    buffer = src,
    callback = function()
      M.render()
    end,
  })
  -- re-wrap if the split is resized
  vim.api.nvim_create_autocmd("WinResized", {
    group = state.group,
    callback = function()
      if not is_open() or rendering then
        return
      end
      -- schedule so the resize has settled before we re-wrap
      vim.schedule(function()
        if is_open() then
          M.render()
        end
      end)
    end,
  })
  -- clean up if either window goes away
  vim.api.nvim_create_autocmd({ "WinClosed" }, {
    group = state.group,
    callback = function(ev)
      local w = tonumber(ev.match)
      if w == state.win then
        M.close()
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = state.group,
    buffer = src,
    callback = function()
      M.close()
    end,
  })
end

function M.toggle()
  if is_open() then
    M.close()
  else
    M.open()
  end
end

--- Full-screen, scrollable read via glow's own pager.
function M.pager()
  if vim.fn.executable("glow") == 0 then
    vim.notify("glow is not on PATH — run `mise install glow`", vim.log.levels.ERROR)
    return
  end
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("Save the file first", vim.log.levels.WARN)
    return
  end
  Snacks.terminal.open({ "glow", "-p", "-s", "auto", file }, {
    interactive = true,
    win = { style = "float", width = 0.9, height = 0.9, border = "rounded" },
  })
end

return M
