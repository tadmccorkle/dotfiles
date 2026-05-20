vim.api.nvim_create_user_command("Dev", function()
	require("tad.dev.env").setup()
end, { desc = "dev: open dev environment" })
