vim.api.nvim_create_user_command("CDev", function()
	require("tad.dev.c").setup()
end, { desc = "c-dev: open C dev layout" })
