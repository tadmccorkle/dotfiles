local status, ls = pcall(require, 'luasnip')
if not status then return end

ls.setup({
	update_events = 'TextChanged,TextChangedI',
	region_check_events = 'CursorMoved,InsertEnter',
})
