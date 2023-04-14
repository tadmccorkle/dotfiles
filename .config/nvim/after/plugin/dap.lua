local status1, dap = pcall(require, 'dap')
local status2, vtext = pcall(require, 'nvim-dap-virtual-text')

local status = status1 and status2
if not status then return end


-- mappings
local map = require('tad.map')
local opts = { noremap = true, silent = true }

local widgets = require('dap.ui.widgets')

map('n', '<F2>', function() dap.step_into() end, opts)
map('n', '<F3>', function() dap.step_over() end, opts)
map('n', '<F4>', function() dap.step_out() end, opts)
map('n', '<F5>', function() dap.continue() end, opts)
map('n', '<Leader>b', function() dap.toggle_breakpoint() end, opts)
map('n', '<Leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, opts)
map('n', '<Leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, opts)
map('n', '<Leader>Dr', function() dap.repl.open() end, opts)
map('n', '<Leader>Dl', function() dap.run_last() end, opts)
map({ 'n', 'v' }, '<Leader>Dh', function() widgets.hover() end, opts)
map({ 'n', 'v' }, '<Leader>Dp', function() widgets.preview() end, opts)
map('n', '<Leader>Df', function() widgets.centered_float(widgets.frames) end, opts)
map('n', '<Leader>Ds', function() widgets.centered_float(widgets.scopes) end, opts)


-- adapters and configurations
-- a Rust config lived here once, but debugging support on Windows outside of VSCode was pretty lackluster...
-- will debug Rust programs in VS2022 until things improve


---@diagnostic disable-next-line: missing-parameter
vtext.setup()
