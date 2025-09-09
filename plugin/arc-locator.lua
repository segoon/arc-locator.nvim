local vim = vim

local function open_in_arcadia(fname, old_bufnr)
  vim.schedule(
    function()
      vim.cmd{cmd = 'edit', args = { fname }}
      vim.api.nvim_buf_delete(old_bufnr, {})
    end
  )
end

local function on_new_file()
  local wait_obj = vim.system({'arc', 'root'}, {text=true}):wait()
  local root = wait_obj.stdout:gsub('%s*$', '')
  if root == '' then
    return
  end

  local fname = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  fname = vim.fs.relpath(cwd, fname)
  fname = root .. '/' .. fname

  if not vim.uv.fs_stat(fname) then
    return
  end

  vim.ui.input(
    { prompt = 'Open file in acradia? [Y/n]' },
    function(input)
      if input == '' or input == 'y' or input == 'Y' then
        bufnr = vim.api.nvim_get_current_buf()
        open_in_arcadia(fname, bufnr)
      end
    end
  )
end

vim.api.nvim_create_autocmd('BufNewFile', {callback=on_new_file})
