local utils = require("xplr.utils")
local root = utils.get_root()
local uv = vim.loop

local Job = require("plenary.job")

local Split = require("nui.split")

local split = Split({
  relative = "win",
  position = "right",
  size = "20%",
})

local install = {}

--- Check if we have a valid display window
local valid_display = function(split)
  return split and vim.api.nvim_buf_is_valid(split.bufnr) and vim.api.nvim_win_is_valid(split.winid)
end
--- Update the text of the display buffer
local set_lines = vim.schedule_wrap(function(lines)
  if not valid_display(split) then
    return
  end
  vim.api.nvim_buf_set_option(split.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(split.bufnr, -1, -1, true, lines)
  vim.api.nvim_buf_set_option(split.bufnr, "modifiable", false)
end)

local function on_stdout(err, data)
  set_lines({ data })
end

local function luv_mpack_exist()
  local luv_exist = uv.fs_stat(("%s/xplr/src/luv/luv.so"):format(utils.get_root()))
  local mpack_exist = uv.fs_stat(("%s/xplr/src/libmpack/mpack.so"):format(utils.get_root()))
  return luv_exist, mpack_exist
end

local function install_luv_mpack(luv_exist, mpack_exist)
  local luv_completed = false
  local mpack_completed = false

  local luv_job = Job:new({
    command = "make",
    cwd = ("%s/xplr/src/luv"):format(root),
    --args = { [['luv job started']] },
    on_stdout = on_stdout,
    on_stderr = on_stdout,
    on_exit = function()
      set_lines({ "luv build process exited" })
    end,
  })

  local mpack_out = {}
  local mpack_job = Job:new({
    command = "make",
    cwd = ("%s/xplr/src/luv"):format(root),
    --args = { [['mpack job started']] },
    on_stdout = function(err, data)
      if not luv_completed then
        table.insert(mpack_out, data)
      else
        set_lines({ data })
      end
    end,
    on_stderr = on_stdout,
    on_exit = function()
      set_lines({ "mpack build process exited" })
    end,
  })

  local function after_all_jobs_complete()
    local luv_exist, mpack_exist = luv_mpack_exist()

    if not luv_exist then
      set_lines({ "Luv failed to build - try building manually" })
    end

    if not mpack_exist then
      set_lines({ "mpack failed to build - try building manually" })
    end
  end

  if not luv_exist then
    set_lines({ "==== luv.so not found - Building.. ====" })
    luv_job:start()
    luv_job:after(function()
      if not mpack_exist then
        set_lines({ "==== mpack.so not found - Building.. ====" })
        set_lines(mpack_out)
      end
      luv_completed = true

      if not mpack_exist and mpack_completed then
        after_all_jobs_complete()
      end
    end)
  else
    set_lines({ "Luv already built" })
  end
  if not mpack_exist then
    set_lines({ "mpack.so not found - building" })

    mpack_job:start()
    mpack_job:after(function()
      if not luv_exist and luv_completed then
        after_all_jobs_complete()
      end
    end)
  else
    set_lines({ "mpack already built" })
  end
end

local install = function()
  --local luv_exist = false
  --local mpack_exist = false
  --local submodule_exist = false
  local luv_exist, mpack_exist = luv_mpack_exist()
  local submodule_exist = utils.check_git_submodule(root)
  local exit_here = luv_exist and mpack_exist and submodule_exist

  if exit_here then
    print("xplr.nvim dependencies already installed")
    return
  end

  local submodule_job = Job:new({
    command = "git",
    args = { "submodule", "update", "--init", "--recursive" },
    cwd = root,
    on_stdout = on_stdout,
    on_stderr = on_stdout,
    on_exit = on_exit,
  })

  split:mount()
  vim.api.nvim_buf_set_lines(split.bufnr, 0, 0, true, { "Installing xplr lua client dependencies.." })

  if not submodule_exist then
    set_lines({ "==== Submodules not found - Cloning.. ====" })
    submodule_job:start()
    submodule_job:after_success(function()
      set_lines({ "Submodules cloned successfully" })
      install_luv_mpack(luv_exist, mpack_exist)
    end)
  else
    set_lines({ "Submodules found" })
    install_luv_mpack(luv_exist, mpack_exist)
  end
end

return { install = install }
